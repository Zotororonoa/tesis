import pandas as pd
import numpy as np
import base64
import os

def mapminmax(data, new_min, new_max):
    data_min = np.nanmin(data, axis=0)  # Usar nanmin para ignorar NaN
    data_max = np.nanmax(data, axis=0)  # Usar nanmax para ignorar NaN
    normalized_data = (data - data_min) / (data_max - data_min) * (new_max - new_min) + new_min
    return normalized_data

def normalizar_csv(base64_csv, tipo_normalizacion, nombre_archivo_salida):
    # Decodificar base64 a CSV
    csv_decodificado = base64.b64decode(base64_csv).decode('utf-8')

    # Convertir la cadena CSV a DataFrame de Pandas
    from io import StringIO
    datos = pd.read_csv(StringIO(csv_decodificado))

    # Convertir todas las cadenas que representan números a valores numéricos
    for col in datos.columns:
        datos[col] = pd.to_numeric(datos[col].astype(str).str.replace(',', '.'), errors='coerce')

    # Separar las columnas a normalizar y la última columna
    columnas_a_normalizar = datos.columns[:-1]  # Todas las columnas menos la última
    ultima_columna = datos.columns[-1]         # La última columna

    # Normalizar los datos según el tipo proporcionado, excluyendo la última columna
    if tipo_normalizacion == "0":
        datos_normalizados = mapminmax(datos[columnas_a_normalizar].values, 0, 1)
    elif tipo_normalizacion == "1":
        datos_normalizados = mapminmax(datos[columnas_a_normalizar].values, -1, 1)
    else:
        raise ValueError("Tipo de normalización inválido. Use '0' para [0, 1] o '1' para [-1, 1].")

    # Redondear los datos normalizados a un solo decimal
    datos_normalizados = np.round(datos_normalizados, 1)

    # Convertir los datos normalizados de nuevo a DataFrame y añadir la última columna sin cambios
    df_normalizado = pd.DataFrame(datos_normalizados, columns=columnas_a_normalizar)
    df_normalizado[ultima_columna] = datos[ultima_columna].values

    # Guardar los datos normalizados en un nuevo archivo CSV
    directorio_salida = '/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB'
    ruta_salida = os.path.join(directorio_salida, nombre_archivo_salida)
    df_normalizado.to_csv(ruta_salida, index=False)
    
    return ruta_salida

# Ejemplo de uso:
# base64_csv = 'tu_cadena_csv_codificada_en_base64_aqui'
# tipo_normalizacion = '0'  # o '1' para [-1, 1]
# nombre_archivo_salida = 'nombre_del_archivo.csv'
# ruta_archivo = normalizar_csv(base64_csv, tipo_normalizacion, nombre_archivo_salida)
# print(f"Archivo normalizado guardado en: {ruta_archivo}")