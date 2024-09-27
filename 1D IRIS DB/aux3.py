from oct2py import octave
import matplotlib.pyplot as plt
import numpy as np
import io
import base64
import os

# Añadir la ruta a la función de Octave
ruta = "/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB"
octave.addpath(ruta)

M = 0.8
neuronas = 120
entradaBD = "iris.dt"
var = "0"  # Variable para optimización ("0" para G-mean, "1" para Accuracy)
paso = 5  # Tamaño de paso

# Formatear correctamente el script con la cadena entre comillas
script = f"exhaustiva({M},{neuronas},'{entradaBD}','{var}',{paso})"

try:
    # Llamar a la función de Octave
    neuronas_ocultas, Obj_pond, pondAcc, pondGmean, acc_list, gmean_list = octave.eval(script, nout=6)

    # Imprimir los resultados
    print(f"Neuronas Ocultas: {neuronas_ocultas}")
    print(f"Obj Pond: {Obj_pond}")
    print(f"Acc List: {acc_list}")
    print(f"Gmean List: {gmean_list}")
    print(f"Obj Pond shape: {np.array(Obj_pond[0]).shape}")
    print(f"neuronas_ocultas shape: {np.array(neuronas_ocultas[0]).shape}")
except Exception as e:
    print(f"Error al ejecutar el script de Octave: {e}")

# Crear gráficos a partir de los resultados
graphs_base64 = []
neuronas = [item for sublist in neuronas_ocultas for item in sublist]
print(f"Neuronas: {neuronas}")
mean_fObj_pond = np.mean(Obj_pond[0], axis=0)
print(f"Mean fObj Pond: {mean_fObj_pond.shape}")
plt.plot(neuronas, mean_fObj_pond)
plt.xlabel('Neuronas ocultas')
plt.ylabel('Performance')
plt.grid()
plt.show()