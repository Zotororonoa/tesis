from celery_config import make_celery
from oct2py import octave
from pymongo import MongoClient
import numpy as np
import io
import base64
import matplotlib.pyplot as plt

celery = make_celery()

# Conexión a MongoDB
client = MongoClient('mongodb://localhost:27017/')
db = client['tasks_db']
exhaustiva_tasks_collection = db['exhaustiva_tasks']
ao_tasks_collection = db['AO_tasks']

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
def run_octave_script(self, N, T, UB):
    task_id = self.request.id
    task_doc = {
        '_id': task_id,
        'status': 'PENDING'
    }
    exhaustiva_tasks_collection.insert_one(task_doc)
    
    try:
        ruta = "/Users/diegobravosoto/Desktop/codigos_dos/1D IRIS DB"
        octave.addpath(ruta)
        neuronas, Obj_pond, accuracy_list, gmean_list, data_set = octave.eval(f"exhaustiva({N},{T},{UB})", nout=5)

        lista_simple = [item for sublist in accuracy_list for item in sublist]
        lista_simple_dos = [item for sublist in gmean_list for item in sublist]

        Obj_pond = [np.array(matrix) for matrix in Obj_pond]
        graphs_base64 = []

        for i in range(len(Obj_pond[0])):
            mean_fObj_pond = np.mean(Obj_pond[0][i], axis=0)
            titulo = f'Exhaustive search in dataset IRIS, Accuracy: {accuracy_list[0][i]}, Gmean: {gmean_list[0][i]}'

            plt.plot(neuronas[0], mean_fObj_pond)
            plt.xlabel('Neuronas ocultas')
            plt.ylabel('Performance')
            plt.grid()
            plt.title(titulo)

            buf = io.BytesIO()
            plt.savefig(buf, format='png')
            buf.seek(0)

            img_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
            graphs_base64.append(img_base64)
            plt.close()

        result = {
            'data_set': convert_to_serializable(data_set),
            'neuronas': convert_to_serializable(neuronas),
            'accuracy_list': convert_to_serializable(lista_simple),
            'gmean_list': convert_to_serializable(lista_simple_dos),
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
def run_aquila_script(self, N, T):
    task_id = self.request.id
    task_doc = {
        '_id': task_id,
        'status': 'PENDING'
    }
    ao_tasks_collection.insert_one(task_doc)
    
    try:
        ruta = "/Users/diegobravosoto/Desktop/codigos_dos/1D IRIS DB"
        octave.addpath(ruta)
        N, T, conv, accuracy_list, gmean_list, cantIterPorc = octave.feval(f"aquila({N},{T})", nout=6)
        
        result = {
            'N': convert_to_serializable(N),
            'T': convert_to_serializable(T),
            'cantIterPorc': convert_to_serializable(cantIterPorc),
            'accuracy_list': convert_to_serializable(accuracy_list),
            'gmean_list': convert_to_serializable(gmean_list),
            'conv': convert_to_serializable(conv)
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
