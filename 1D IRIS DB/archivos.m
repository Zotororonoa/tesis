function [muestras, atributos, clases] = archivos(nombre_archivo)

  % Obtener la extensión del archivo
  [~, ~, extension] = fileparts(nombre_archivo);

  % Leer el archivo y contar filas y columnas según la extensión
  switch extension
    case '.csv'
      datos = csvread(nombre_archivo);
    case '.dt'
      datos = load(nombre_archivo);
    otherwise
      error('Formato de archivo no soportado. Solo se admiten archivos .csv y .dt.');
  end

  % Contar filas y columnas
  [muestras, atributos] = size(datos);

  % Mostrar los resultados
  fprintf('El archivo %s tiene %d filas (muestras) y %d columnas (atributos).\n', nombre_archivo, muestras, atributos-1);

  % Calcular y mostrar la cantidad de valores distintos en la última columna
  ultima_columna = datos(:, end);
  clases = numel(unique(ultima_columna));
  fprintf('La última columna tiene %d valores distintos (clases).\n', clases);
end
