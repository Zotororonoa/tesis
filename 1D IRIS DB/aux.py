from oct2py import octave
import matplotlib.pyplot as plt
import numpy as np
import io
import base64
import os


N=10
T=10
neuronas=120
muestras=0.8

# Add path to the Octave function
ruta = "/Users/diegobravosoto/Desktop/proyecto_de_titulo/tesis/1D IRIS DB"
octave.addpath(ruta)

nombre_archivo = "iris.dt"
ruta_completa = os.path.join(ruta, nombre_archivo)

if not os.path.exists(ruta_completa):
    raise FileNotFoundError(f"El archivo {ruta_completa} no existe.")

# Ensure the file name is correctly passed as a string
script_tres = f"archivos('{nombre_archivo}')"

print(f"Ejecutando el script: {script_tres}")

# Ejecutar y obtener los resultados
try:
    muestras, atributos, clases = octave.eval(script_tres, nout=3)
    print(f"Muestras: {muestras}, Atributos: {atributos}, Clases: {clases}")
except Exception as e:
    print(f"Error al ejecutar el script en Octave: {e}")


# Call the Octave function
#neuronas_ocultas, Obj_pond, acc_list, gmean_list = octave.eval(script, nout=4)




























#Nr, Tr, conv, k, accuracy_list, gmean_list, cantIterPorc = octave.feval("aquila", nout=7)
#lista_simple = [item for sublist in conv for item in sublist]

# Puedes cambiar este valor por el que desees

# print(len(conv[0][0]))

# lista = list(range(1, len(conv[0][0])+1))
# print(lista)




# for i in range(len(conv[0])):
#     promedios = np.mean(conv[0][i], axis=1)

#     plt.plot(lista, promedios)
#     plt.xlabel('Iteraciones')
#     plt.ylabel('Performance')
#     plt.grid()
#     plt.title('Aquila')
#     plt.show()








# print(acc_list)
# lista_simple = [item for sublist in acc_list for item in sublist]
# print(lista_simple)


#print(neuronas_ocultas)

# Convert Octave output to Python lists
#neuronas_ocultas = list(map(lambda x: x.tolist(), neuronas_ocultas))


# Convert Obj_pond to a numpy array for easier manipulation
#Obj_pond = [np.array(matrix) for matrix in Obj_pond]


# Lista para almacenar los gráficos en formato base64
#graphs_base64 = []




# Commented code
# for i in range(len(Obj_pond[0])):
#     # Compute the mean of Obj_pond across all iterations
#     mean_fObj_pond = np.mean(Obj_pond[0][i], axis=0)
#     #print(mean_fObj_pond.shape)

#     titulo = str('Exhaustive search in dataset IRIS, Accuracy: ' + str(acc_list[0][i]) + ', Gmean: ' + str(gmean_list[0][i]))
#     #print(titulo)

# # Plot the results
#     plt.plot(neuronas_ocultas[0], mean_fObj_pond)
#     plt.xlabel('Neuronas ocultas')
#     plt.ylabel('Performance')
#     plt.grid()
#     plt.title(titulo)
#     plt.show()

#     # Save the plot to a BytesIO object
#     buf = io.BytesIO()
#     plt.savefig(buf, format='png')
#     buf.seek(0)

#     # Encode the BytesIO object to base64
#     img_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
#     graphs_base64.append(img_base64)

#     # Clear the current plot
#     plt.close()