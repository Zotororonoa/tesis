function [neuronas_ocultas, Obj_pond, acc_list, gmean_list]=exhaustiva(N, T, UB)

%clear
%clc
%close all

entradaBD="iris.dt";

archivo=load(entradaBD);


%La suma de las ponderaciones de Accuracy y Gmean deben sumar 1
modoPonderado = true;
if(modoPonderado==true)
    inicio=0;
    fin=1;
else
    inicio = 0.5;
    fin = 0.5;
end





%Dominio de las variables/ejes y n�mero de dimensiones
LB=1;
tamano=size(archivo);
%UB=ceil(tamano(1)*0.8);

%UB=800;
Dim=1;

k=5;
particion = 1-1/k;

neuronas_ocultas=LB:UB;
exac_testeo = zeros(k,length(neuronas_ocultas));
mg_testeo = zeros(k,length(neuronas_ocultas));
fObj_pond = zeros(k,length(neuronas_ocultas));

% Lista para almacenar cada instancia de fObj_pond
fObj_pond_list = {};

%listas para enviar datos acc y gmean
acc_list = {};
gmean_list = {};



%Calculo del porcentaje para an�lisis de convergencia inicial
porcentaje=15;
cantIterPorc = ceil((porcentaje*UB)/(100*N));

%Inicializaci�n de variables necesarias
Best_FF=zeros(1,k);
Best_P=zeros(k,Dim);
conv=zeros(k,cantIterPorc);
convAcc=zeros(k,cantIterPorc);
convGmean=zeros(k,cantIterPorc);

repeticiones=1;

for macroCiclo=inicio:0.1:fin

    pondAcc = macroCiclo;
    pondGmean = 1 - pondAcc;

    tiempoAO=0;
    tiempoSec=0;
    vectorTiempoAO = zeros(k,cantIterPorc);
    vectorperf15porc = zeros(k,cantIterPorc);
    vectorTiempoExh = zeros(1,k);
    vectorMejorResExh = zeros(1,k);
    vectorMejorPosExh = zeros(1,k);
    vectorMejorPosAO = zeros(1,k);

    %k iteraciones
    for i=1:k
        %Configuraci�n est�ndar para ambos m�todos
        nale=randperm(size(archivo,1));
        bdd=archivo(nale,:);
        entrenamiento=bdd(1:round(length(bdd)*particion),:);
        testeo=bdd(round(length(bdd)*particion)+1:end,:);

        %B�squeda exhaustiva
        tic

        for ii=1:length(neuronas_ocultas)
                [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1,...
                    neuronas_ocultas(ii), 'sig');
                %tiempo_entrenamiento_mean(i,j)=TrainingTime;
                %tiempo_testeo_mean(i,j)=TestingTime;
                %exac_entrenamiento_mean(i,j)=TrainingAccuracy;

            %tiempo_entrenamiento(i,ii)=mean(tiempo_entrenamiento_mean(i));
            %tiempo_testeo(i,ii)=mean(tiempo_testeo_mean(i));
            %exac_entrenamiento(i,ii)=mean(exac_entrenamiento_mean(i));
            exac_testeo(i,ii) = TestingAccuracy;
            mg_testeo(i,ii) = test_gmean;
            fObj_pond(i,ii) = exac_testeo(i,ii)*pondAcc + mg_testeo(i,ii)*pondGmean;
            if(vectorMejorResExh(i)<fObj_pond(i,ii))
                vectorMejorResExh(i)=fObj_pond(i,ii);
                vectorMejorPosExh(i)=ii;
            end
        end
        vectorTiempoExh(i) = toc;
    end

    % Guardar cada instancia de fObj_pond en la lista
    fObj_pond_list{end+1} = fObj_pond;
    acc_list{end+1} = pondAcc;
    gmean_list{end+1} = pondGmean;
    
    

    %Guardar resultados
        MediaMejores=mean(max(fObj_pond')); %Es el promedio de los mejores
        MejorDeMejores=max(max(fObj_pond));
        mejorSTD = std(reshape(fObj_pond,[],1));



        desvEstandar = std(conv(:,end));
        valorMayorProm = mean(conv(:,end));

        desAOTimeSTD = std(vectorTiempoAO);
        desAOTimeMean = mean(vectorTiempoAO);

        aux=strcat("Prueba ACC_",num2str(pondAcc),"_y_GMEAN_",num2str(pondGmean),".mat");
        save(aux)

    %Convergencia de b�squeda exhaustiva
    %x=neuronas_ocultas;
    %y=mean(fObj_pond(:,:));
    %figure, plot(x,y);hold on; grid on; grid minor;
    %xlabel('N� Neurals');
    %ylabel('Performance');
    %cadAux=strcat("Exhaustive Search in dataset ",entradaBD,...
    %    ", ","Accuracy: ",num2str(pondAcc)," and G-mean: ",num2str(pondGmean));
    %title(cadAux);

   
end
% Devolver la lista de fObj_pond
Obj_pond = fObj_pond_list;

disp(N);
disp(T);
disp(UB);



% Mostrar conv_list en la terminal
%disp('Convergence List:');
%disp(Obj_pond);

end
