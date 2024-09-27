from flask import Flask, request, jsonify
from tasks import run_octave_script, run_aquila_script, process_base64_csv, run_archivos_script, normalizar_csv_task
from celery_config import make_celery
import base64

def create_app():
    app = Flask(__name__)
    app.config.update(
        CELERY_BROKER_URL='redis://localhost:6379/0',
        CELERY_RESULT_BACKEND='redis://localhost:6379/0'
    )

    celery = make_celery(app)

    @app.route('/start_task', methods=['POST'])
    def start_task():
        data = request.json
        M = data.get('M')
        neurons = data.get('neurons')
        entradaBD = data.get('entradaBD')
        var = data.get('var')
        paso = data.get('paso')

        if M is None or neurons is None or entradaBD is None or var is None or paso is None:
            return jsonify({'error': 'M, neurons, entradaBD, var, and paso parameters are required'}), 400

        task = run_octave_script.apply_async(args=[M, neurons, entradaBD, var, paso])
        return jsonify({'task_id': task.id}), 202

    @app.route('/start_aquila_task', methods=['POST'])
    def start_aquila_task():
        data = request.json
        M = data.get('M')
        neurons = data.get('neurons')
        entradaBD = data.get('entradaBD')
        var = data.get('var')
        paso = data.get('paso')
        N = data.get('N')
        T = data.get('T')

        if M is None or neurons is None or entradaBD is None or var is None or paso is None or N is None or T is None:
            return jsonify({'error': 'M, neurons, entradaBD, var, paso, N, and T parameters are required'}), 400

        task = run_aquila_script.apply_async(args=[M, neurons, entradaBD, var, paso, N, T])
        return jsonify({'task_id': task.id}), 202

    @app.route('/check_task/<task_type>/<task_id>', methods=['GET'])
    def check_task(task_type, task_id):
        if task_type == 'octave':
            task = run_octave_script.AsyncResult(task_id)
        elif task_type == 'aquila':
            task = run_aquila_script.AsyncResult(task_id)
        elif task_type == 'archivos':
            task = run_archivos_script.AsyncResult(task_id)
        elif task_type == 'normalizacion':
            task = normalizar_csv_task.AsyncResult(task_id)
        else:
            return jsonify({'error': 'Invalid task type'}), 400

        if task.state == 'PENDING':
            response = {
                'state': task.state,
                'current': 0,
                'total': 1,
                'status': 'Pending...'
            }
        elif task.state != 'FAILURE':
            response = {
                'state': task.state,
                'current': 1,
                'total': 1,
                'status': task.info.get('status', ''),
                'result': task.info
            }
            if 'result' in task.info:
                response['result'] = task.info['result']
        else:
            response = {
                'state': task.state,
                'current': 1,
                'total': 1,
                'status': str(task.info),
            }
        return jsonify(response)

    @app.route('/upload_csv', methods=['POST'])
    def upload_csv():
        data = request.json
        base64_str = data.get('base64')
        filename = data.get('filename')
        if base64_str is None or filename is None:
            return jsonify({'error': 'Base64 string and filename are required'}), 400

        task = process_base64_csv.apply_async(args=[base64_str, filename])
        return jsonify({'task_id': task.id}), 202

    @app.route('/start_archivos_task', methods=['POST'])
    def start_archivos_task():
        data = request.json
        nombre_archivo = data.get('nombre_archivo')
        
        if nombre_archivo is None:
            return jsonify({'error': 'nombre_archivo parameter is required'}), 400

        # Iniciar la tarea de Celery
        task = run_archivos_script.apply_async(args=[nombre_archivo])
        
        try:
            # Esperar el resultado con un timeout de 30 segundos
            result = task.get(timeout=10)
            
            # Si la tarea se completa, devolvemos el resultado
            return jsonify(result), 200
        except Exception as e:
            # Si ocurre un error o se excede el tiempo de espera
            return jsonify({'error': str(e)}), 500

    @app.route('/normalizar_csv', methods=['POST'])
    def normalizar_csv_endpoint():
        data = request.json
        base64_csv = data.get('base64_csv')
        tipo_normalizacion = data.get('tipo_normalizacion')
        nombre_archivo_salida = data.get('nombre_archivo_salida')

        if base64_csv is None or tipo_normalizacion is None or nombre_archivo_salida is None:
            return jsonify({'error': 'base64_csv, tipo_normalizacion, and nombre_archivo_salida parameters are required'}), 400

        task = normalizar_csv_task.apply_async(args=[base64_csv, tipo_normalizacion, nombre_archivo_salida])
        return jsonify({'task_id': task.id}), 202

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)