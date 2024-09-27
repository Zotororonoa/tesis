from oct2py import octave
import matplotlib.pyplot as plt
import numpy as np

# Add path to the Octave function
ruta = "/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB"
octave.addpath(ruta)

# Parámetros
N = 15
T = 5
neuronas = 120
M = 0.8
entradaBD = "iris.dt"
var = "0"
paso = 1

# Ejecuta el script de Octave
script = f"aquila2({M},{neuronas},'{entradaBD}','{var}',{paso}, {N}, {T})"
neuronas_ocultas, N, T, conv_list, k, lista_accuracy, lista_gmean, cantIterPorc = octave.eval(script, nout=8)

# Extraer los valores de rendimiento de conv_list (usando conv_list[0] ya que conv_list es una lista de listas)
conv_list = conv_list[0]

# Extraemos el valor de convergencia en cada iteración
# Se asume que se toma la primera columna (que representa el rendimiento en cada iteración)
iteraciones = np.arange(1, len(conv_list) + 1)

print("size conv: ", len(conv_list))
# Promediamos los valores en las filas de cada array en conv_list
promedios_globales = [np.mean(arr[:, 0]) for arr in conv_list]  # Primera columna de cada array



# Graficamos el rendimiento promedio por iteración
plt.plot(iteraciones, promedios_globales, marker='o')
plt.xlabel('Iteraciones')
plt.ylabel('Performance (Convergencia)')
plt.grid()
plt.title('Convergencia del Algoritmo Aquila Optimizer')
plt.show()

print(N)
print(T)
print("conv: ")
print(conv_list)
print("cantIterPorc: ")
print(cantIterPorc)