function [neuronas_ocultas, N, T, conv_list, k, lista_accuracy, lista_gmean, cantIterPorc] = aquila2(M, neuronas, entradaBD, var, paso, N, T)

    %clear
    %clc
    %close all

    pkg load statistics

    % Asegurarse de que el archivo sea cargado correctamente
    archivo = cargarDatos(entradaBD);

    % Listas para almacenar resultados
    aquila_list = {};
    accuracy_list = {};
    gmean_list = {};
    cantIterPorc_list = {};

    % La suma de las ponderaciones de Accuracy y Gmean deben sumar 1
    if var == "0"
        pondAcc = 0;
        pondGmean = 1;
    elseif var == "1"
        pondAcc = 1;
        pondGmean = 0;
    else
        error('Valor de "var" no válido. Debe ser "0" o "1".');
    end

    % Dominio de las variables/ejes y número de dimensiones
    LB = 1;
    tamano = size(archivo);
    UB = ceil(tamano(1) * M);
    Dim = 1;

    k = 5;
    particion = 1 - 1 / k;

    neuronas_ocultas = LB:paso:neuronas;
    exac_testeo = zeros(k, length(neuronas_ocultas));
    mg_testeo = zeros(k, length(neuronas_ocultas));
    fObj_pond = zeros(k, length(neuronas_ocultas));

    % Calculo del porcentaje para análisis de convergencia inicial
    porcentaje = 15;
    cantIterPorc = ceil((porcentaje * UB) / (100 * N));

    % Inicialización de variables necesarias
    Best_FF = zeros(1, k);
    Best_P = zeros(k, Dim);
    conv = zeros(k, cantIterPorc);
    convAcc = zeros(k, cantIterPorc);
    convGmean = zeros(k, cantIterPorc);

    % k iteraciones
    for i = 1:k
        % Configuración estándar
        nale = randperm(size(archivo, 1));
        bdd = archivo(nale, :);
        entrenamiento = bdd(1:round(length(bdd) * particion), :);
        testeo = bdd(round(length(bdd) * particion) + 1:end, :);

        % Aquila Optimizer
        [Best_FF(i), Best_P(i), conv(i,:), convAcc(i,:), convGmean(i,:), tiempos, perf15porc] = AO_MEAN_PERF(N, T, LB, UB, Dim, entrenamiento, testeo, pondAcc, pondGmean, cantIterPorc);

        % Guardar resultados
        aquila_list{end + 1} = conv;
        accuracy_list{end + 1} = pondAcc;
        gmean_list{end + 1} = pondGmean;
        cantIterPorc_list{end + 1} = cantIterPorc;
    end

    % Devolver listas de resultados
    conv_list = aquila_list;
    lista_accuracy = accuracy_list;
    lista_gmean = gmean_list;
    cantIterPorc = cantIterPorc_list;
    disp(conv_list)

end

function datos = cargarDatos(archivo)
    [~, ~, ext] = fileparts(archivo);
    if strcmp(ext, '.dt')
        datos = load(archivo);
    elseif strcmp(ext, '.csv')
        datos = csvread(archivo);
    else
        error('Formato de archivo no soportado. Debe ser ".dt" o ".csv".');
    end
end