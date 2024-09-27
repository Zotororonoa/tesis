from celery_config import make_celery
from oct2py import octave
from pymongo import MongoClient
import numpy as np
import io
import matplotlib.pyplot as plt
import base64
import csv
import os
from normalizacion import normalizar_csv

celery = make_celery()

# Conexión a MongoDB
client = MongoClient('mongodb://localhost:27017/')
db = client['tasks_db']
exhaustiva_tasks_collection = db['exhaustiva_tasks']
ao_tasks_collection = db['AO_tasks']
csv_tasks_collection = db['csv_tasks']

def convert_to_serializable(data):
    if isinstance(data, list):
        return [convert_to_serializable(item) for item in data]
    elif isinstance(data, dict):
        return {key: convert_to_serializable(value) for key, value in data.items()}
    elif isinstance(data, (int, float, str)):
        return data
    else:
        return str(data)

@celery.task(bind=True)
def run_octave_script(self, M, neurons, entradaBD, var, paso):
    task_id = self.request.id
    task_doc = {
        '_id': task_id,
        'status': 'PENDING',
        'Cantidad_muestras': M,
        'cantidad_neurons': neurons,
        'dataset': entradaBD,
        'var': var
    }
    exhaustiva_tasks_collection.insert_one(task_doc)

    try:
        ruta = "/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB"
        octave.addpath(ruta)
        script = f"exhaustiva({M},{neurons},'{entradaBD}','{var}',{paso})"
        neuronas, Obj_pond, accuracy_list, gmean_list = octave.eval(script, nout=4)

        graphs_base64 = []

        neuronas = [item for sublist in neuronas for item in sublist]
        mean_fObj_pond = np.mean(Obj_pond[0], axis=0)
        plt.plot(neuronas, mean_fObj_pond)
        plt.xlabel('Neuronas ocultas')
        plt.ylabel('Performance')
        plt.grid()

        buf = io.BytesIO()
        plt.savefig(buf, format='png', dpi=300)
        buf.seek(0)

        img_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
        graphs_base64.append(img_base64)
        plt.close()

        result = {
            'neuronas': convert_to_serializable(neuronas),
            'accuracy_list': convert_to_serializable(accuracy_list),
            'gmean_list': convert_to_serializable(gmean_list),
            'Obj_pond': convert_to_serializable(Obj_pond),
            'graphs_base64': graphs_base64
        }

        exhaustiva_tasks_collection.update_one({'_id': task_id}, {
            '$set': {
                'status': 'SUCCESS',
                'result': result
            }
        })
        return result
    except Exception as e:
        exhaustiva_tasks_collection.update_one({'_id': task_id}, {
            '$set': {
                'status': 'FAILURE',
                'error': str(e)
            }
        })
        raise e

@celery.task(bind=True)
def run_aquila_script(self, M, neurons, entradaBD, var, paso, N, T):
    task_id = self.request.id
    task_doc = {
        '_id': task_id,
        'status': 'PENDING',
        'Cantidad_muestras': M,
        'cantidad_neurons': neurons,
        'dataset': entradaBD,
        'var': var
    }
    ao_tasks_collection.insert_one(task_doc)

    try:
        # Ruta al script de Octave
        ruta = "/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB"
        octave.addpath(ruta)
        script = f"aquila2({M},{neurons},'{entradaBD}','{var}',{paso}, {N}, {T})"

        # Llamada a la función de Octave
        neuronas_ocultas, N, T, conv_list, k, lista_accuracy, lista_gmean, cantIterPorc = octave.eval(script, nout=8)

        # Procesamiento de los datos
        lista_neuronas = list(neuronas_ocultas[0])
        concatenated_array = np.concatenate([conv_list[0][i] for i in range(len(conv_list[0]))], axis=0)
        promedios_globales = np.mean(concatenated_array, axis=1)

        if len(promedios_globales) < len(lista_neuronas):
            diferencia = len(lista_neuronas) - len(promedios_globales)
            promedios_globales = np.append(promedios_globales, [promedios_globales[-1]] * diferencia)

        # Creación del gráfico
        plt.plot(lista_neuronas, promedios_globales)
        plt.xlabel('Neuronas Ocultas')
        plt.ylabel('Performance')
        plt.grid()
        plt.title('Performance vs Neuronas Ocultas')

        # Guardar el gráfico en formato base64
        buf = io.BytesIO()
        plt.savefig(buf, format='png', dpi=300)
        buf.seek(0)
        img_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
        plt.close()

        result = {
            'neuronas_ocultas': convert_to_serializable(lista_neuronas),
            'N': convert_to_serializable(N),
            'T': convert_to_serializable(T),
            'conv_list': convert_to_serializable(conv_list),
            'lista_accuracy': convert_to_serializable(lista_accuracy),
            'lista_gmean': convert_to_serializable(lista_gmean),
            'cantIterPorc': convert_to_serializable(cantIterPorc),
            'graphs_base64': [img_base64]
        }

        ao_tasks_collection.update_one({'_id': task_id}, {
            '$set': {
                'status': 'SUCCESS',
                'result': result
            }
        })
        return result
    except Exception as e:
        ao_tasks_collection.update_one({'_id': task_id}, {
            '$set': {
                'status': 'FAILURE',
                'error': str(e)
            }
        })
        raise e
    
@celery.task(bind=True)
def process_base64_csv(self, base64_str, filename):
    task_id = self.request.id
    task_doc = {
        '_id': task_id,
        'status': 'PENDING'
    }
    csv_tasks_collection.insert_one(task_doc)
    
    try:
        # Decodificar la cadena base64
        csv_bytes = base64.b64decode(base64_str)
        
        # Leer el contenido como texto
        csv_text = csv_bytes.decode('utf-8')
        
        # Guardar el contenido como un archivo .csv
        file_path = f'/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB/{filename}'
        with open(file_path, 'w', newline='') as csv_file:
            csv_file.write(csv_text)
        
        result = {
            'status': 'File saved successfully',
            'file_path': file_path
        }

        csv_tasks_collection.update_one({'_id': task_id}, {
            '$set': {
                'status': 'SUCCESS',
                'result': result
            }
        })
        return result
    except Exception as e:
        csv_tasks_collection.update_one({'_id': task_id}, {
            '$set': {
                'status': 'FAILURE',
                'error': str(e)
            }
        })
        raise e

@celery.task(bind=True)
def run_archivos_script(self, nombre_archivo):
    task_id = self.request.id
    ruta = "/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB"
    octave.addpath(ruta)
    ruta_completa = os.path.join(ruta, nombre_archivo)
    
    if not os.path.exists(ruta_completa):
        raise FileNotFoundError(f"El archivo {ruta_completa} no existe.")
    
    script_tres = f"archivos('{nombre_archivo}')"
    print(script_tres)
    try:
        muestras, atributos, clases = octave.eval(script_tres, nout=3)
        result = {
            'muestras': convert_to_serializable(muestras),
            'atributos': convert_to_serializable(atributos),
            'clases': convert_to_serializable(clases)
        }
        return result
    except Exception as e:
        raise e

@celery.task(bind=True)
def normalizar_csv_task(self, base64_csv, tipo_normalizacion, nombre_archivo_salida):
    try:
        ruta_salida = normalizar_csv(base64_csv, tipo_normalizacion, nombre_archivo_salida)
        result = {
            'status': 'File normalized successfully',
            'file_path': ruta_salida
        }
        return result
    except Exception as e:
        raise e