from flask import Flask, request, jsonify
from tasks import run_octave_script

def create_app():
    app = Flask(__name__)
    app.config.update(
        CELERY_BROKER_URL='redis://localhost:6379/0',
        CELERY_RESULT_BACKEND='redis://localhost:6379/0'
    )

    @app.route('/start_task', methods=['POST'])
    def start_task():
        task = run_octave_script.apply_async()
        return jsonify({'task_id': task.id}), 202

    @app.route('/check_task/<task_id>', methods=['GET'])
    def check_task(task_id):
        task = run_octave_script.AsyncResult(task_id)
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
                'status': str(task.info),  # this is the exception raised
            }
        return jsonify(response)

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
