function [neuronas_ocultas, Obj_pond, pondAcc, pondGmean] = exhaustiva(M, neuronas, entradaBD, var, paso)

    %clear
    %clc
    %close all

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

    N = 10;
    T = 10;

    % Dominio de las variables/ejes y número de dimensiones
    LB = 1;
    tamano = size(cargarDatos(entradaBD));
    UB = ceil(tamano(1) * M);

    % UB = 800;
    Dim = 1;

    k = 5;
    particion = 1 - 1 / k;

    neuronas_ocultas = LB:paso:neuronas;
    exac_testeo = zeros(k, length(neuronas_ocultas));
    mg_testeo = zeros(k, length(neuronas_ocultas));
    fObj_pond = zeros(k, length(neuronas_ocultas));

    % Lista para almacenar cada instancia de fObj_pond
    fObj_pond_list = {};

    % Listas para enviar datos acc y gmean
    acc_list = {};
    gmean_list = {};

    % Calculo del porcentaje para análisis de convergencia inicial
    porcentaje = 15;
    cantIterPorc = ceil((porcentaje * UB) / (100 * N));

    % Inicialización de variables necesarias
    Best_FF = zeros(1, k);
    Best_P = zeros(k, Dim);
    conv = zeros(k, cantIterPorc);
    convAcc = zeros(k, cantIterPorc);
    convGmean = zeros(k, cantIterPorc);

    repeticiones = 1;

    tiempoAO = 0;
    tiempoSec = 0;
    vectorTiempoAO = zeros(k, cantIterPorc);
    vectorperf15porc = zeros(k, cantIterPorc);
    vectorTiempoExh = zeros(1, k);
    vectorMejorResExh = zeros(1, k);
    vectorMejorPosExh = zeros(1, k);
    vectorMejorPosAO = zeros(1, k);

    % k iteraciones
    for i = 1:k
        % Configuración estándar para ambos métodos
        archivo = cargarDatos(entradaBD);
        nale = randperm(size(archivo, 1));
        bdd = archivo(nale, :);
        entrenamiento = bdd(1:round(length(bdd) * particion), :);
        testeo = bdd(round(length(bdd) * particion) + 1:end, :);

        % Búsqueda exhaustiva
        tic

        for ii = 1:length(neuronas_ocultas)
            [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean] = ELM(entrenamiento, testeo, 1, neuronas_ocultas(ii), 'sig');

            if var == "0"
                fObj_pond(i, ii) = test_gmean;
            elseif var == "1"
                fObj_pond(i, ii) = TestingAccuracy;
            end

            if vectorMejorResExh(i) < fObj_pond(i, ii)
                vectorMejorResExh(i) = fObj_pond(i, ii);
                vectorMejorPosExh(i) = ii;
            end
        end
        vectorTiempoExh(i) = toc;
    end

    % Guardar cada instancia de fObj_pond en la lista
    fObj_pond_list{end + 1} = fObj_pond;
    acc_list{end + 1} = pondAcc;
    gmean_list{end + 1} = pondGmean;

    % Guardar resultados
    MediaMejores = mean(max(fObj_pond')); % Es el promedio de los mejores
    MejorDeMejores = max(max(fObj_pond));
    mejorSTD = std(reshape(fObj_pond, [], 1));

    desvEstandar = std(conv(:, end));
    valorMayorProm = mean(conv(:, end));

    desAOTimeSTD = std(vectorTiempoAO);
    desAOTimeMean = mean(vectorTiempoAO);

    aux = strcat("Prueba ACC_", num2str(pondAcc), "_y_GMEAN_", num2str(pondGmean), ".mat");
    save(aux)

    % Convergencia de búsqueda exhaustiva
    x = neuronas_ocultas;
    y = mean(fObj_pond(:,:));
    figure, plot(x, y); hold on; grid on; grid minor;
    xlabel('N° Neurons');
    ylabel('Performance');
    cadAux = strcat("Exhaustive Search in dataset ", entradaBD, ", ", "Accuracy: ", num2str(pondAcc), " and G-mean: ", num2str(pondGmean));
    title(cadAux);

    % Devolver la lista de fObj_pond
    Obj_pond = fObj_pond_list;

    disp(UB);

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
