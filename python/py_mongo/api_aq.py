from flask import Flask, request, jsonify
from tasks import run_octave_script, run_aquila_script
from celery_config import make_celery

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
        N = data.get('N')
        T = data.get('T')
        UB = data.get('UB')
        if N is None or T is None or UB is None:
            return jsonify({'error': 'N and T parameters are required'}), 400

        task = run_octave_script.apply_async(args=[N, T, UB])
        return jsonify({'task_id': task.id}), 202

    @app.route('/start_aquila_task', methods=['POST'])
    def start_aquila_task():
        data = request.json
        N = data.get('N')
        T = data.get('T')
        if N is None or T is None:
            return jsonify({'error': 'N and T parameters are required'}), 400

        task = run_aquila_script.apply_async(args=[N, T])
        return jsonify({'task_id': task.id}), 202

    @app.route('/check_task/<task_type>/<task_id>', methods=['GET'])
    def check_task(task_type, task_id):
        if task_type == 'octave':
            task = run_octave_script.AsyncResult(task_id)
        elif task_type == 'aquila':
            task = run_aquila_script.AsyncResult(task_id)
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

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
