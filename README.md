#Nombre del proyecto:
App multiplataforma para la parametrizaçion de algorimos de aprendizaje supervisado.
# Descripción del Proyecto
Este proyecto utiliza Octave para la ejecución de algoritmos de ML, administrado mediante Celery y Redis para tareas asincrónicas, con MongoDB como base de datos y Flutter para la visualización de resultados además de dar las opciones correspondientes para la parametrizacion.

El cliente es capaz de comunicarse e interactúar con el servidor mediante una API REST creada en Python utilizando el micro framework de FLASK. Esta API sirve como intermediario para comunicar los datos que vienen desde el cliente hasta una correspondiente tarea de celery.

# Características principales
- Integración de Octave con Python usando Oct2Py.
- Uso de Celery y Redis para la ejecución de tareas asincrónicas.
- Almacenamiento y procesamiento de datos con MongoDB.
- Interfaz multiplataforma desarrollada con Flutter para visualizar los resultados.

# Requisitos previos (Prerequisites)
Lista de dependencias necesarias:
- Python 3.12+
- Octave 9.1+
- MongoDB 7.0+
- Redis Server 7.2.5 (Obligatorio)
- Flutter SDK

## Instalación

1. Clona el repositorio:
    ```bash
    git clone https://github.com/Zotororonoa/tesis
    cd tesis
    ```

2. Instala las dependencias:
    ```bash
    python3 -m venv env
source env/bin/activate
pip install celery numpy matplotlib flask oct2py 

    ```

3. Inicia Redis Server:
    ```bash
    redis-server
    ```

4. Inicia MongoDB:
    ```bash
    mongod
    ```

5.  Iniciar Celery:
    ```bash
    cd python/py_mongo
	celery -A tasks worker --loglevel=info --pool=solo   
    ```

6. Iniciár API REST:

    ```bash
    cd python/py_mongo
	python3 api_aq.py     
    ```

7. Instalar dependencias y compilar la app de Flutter:
    ```bash
    flutter pub get
    flutter run
    ```
**Recordatorio:** es necesario tener instalado Android Studio y descargar el SDK de android. En caso de querer trabajar con IOS o MacOS instalar Xcode (solo para dispositivos Apple).

# Estructura del Proyecto
##### Directorios:

```bash
/tesis/1D IRIS DB                    # Directorio Octabe/Matlab
/tesis/app                              # Aplicación móvil Flutter
/tesis/python/py_mongo          #Directorio de la API REST y las Celery taks

```

##### Scripts importantes:
```bash
/tesis/python/py_mongo/api_aq.py               #Script API REST
/tesis/python/py_mongo/tasks.py                 #Script tareas Celery
/tesis/python/py_mongo/normalizacion.py     #Script que busca la normalización de los datos 
/tesis/python/py_mongo/celery_config.py      #Cofiguracion de Celery
```


## Contribuciones
Si quieres colaborar, sigue estos pasos:

1. Haz un fork del proyecto.
2. Crea una rama nueva (`git checkout -b feature`).
3. Envía un pull request.

o también puedes comenzar a trabajar desde donde el proyecto terminó.

## Contacto
Si tienes preguntas, contacta a: diego.bravo.01@alu.ucm.cl

