from celery_config import make_celery
from oct2py import octave

celery = make_celery()

@celery.task
def run_octave_script():
    ruta = "/Users/diegobravosoto/Desktop/codigos_dos/1D IRIS DB"
    octave.addpath(ruta)
    N, T, Obj_pond = octave.feval("exhaustiva", nout=3)
    return {'N': convert_to_serializable(N), 'T': convert_to_serializable(T), 'Obj_pond': convert_to_serializable(Obj_pond)}


def convert_to_serializable(data):
    if isinstance(data, list):
        return [convert_to_serializable(item) for item in data]
    elif isinstance(data, dict):
        return {key: convert_to_serializable(value) for key, value in data.items()}
    elif isinstance(data, (int, float, str)):
        return data
    else:
        # Para otros tipos de datos de Octave, conviértelos a listas o diccionarios
        return str(data)