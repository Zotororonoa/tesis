function [N,T,conv_list, k, lista_accuracy, lista_gmean, cantIterPorc]=aquila()

%clear
%clc
%close all

pkg load statistics


entradaBD="iris.dt";

archivo=load(entradaBD);
%entrenamiento=diabetes2(1:round(length(diabetes2)/2),:);
%testeo=diabetes2(round(length(diabetes2)/2)+1:end,:);

%Ver despu�s con Amelia
%entrenamiento_90=diabetes2(round(length(diabetes2)/2)+1:end,:);
%validacion=diabetes2(round(length(diabetes2)/2)+1:end,:);

%aquila list
aquila_list = {};

%Lista para ACC
accuracy_list = {};
gmean_list = {};
cantIterPorc_list = {};

%La suma de las ponderaciones de Accuracy y Gmean deben sumar 1
modoPonderado = true;
if(modoPonderado==true)
    inicio=0;
    fin=1;
else
    inicio = 0.5;
    fin = 0.5;
end

%N�mero de �guilas y N�mero de iteraciones (por defecto 10)
N=10;
T=10;

%Dominio de las variables/ejes y n�mero de dimensiones
LB=1;
tamano=size(archivo);
UB=ceil(tamano(1)*0.8);

%UB=800;
Dim=1;

k=5;
particion = 1-1/k;

neuronas_ocultas=LB:UB;
exac_testeo = zeros(k,length(neuronas_ocultas));
mg_testeo = zeros(k,length(neuronas_ocultas));
fObj_pond = zeros(k,length(neuronas_ocultas));

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

        %Aquila Optimizer
        [Best_FF(i),Best_P(i),conv(i,:),convAcc(i,:),convGmean(i,:),tiempos,perf15porc]=AO_MEAN_PERF(N...
            ,T,LB,UB,Dim,entrenamiento,testeo,pondAcc, pondGmean,cantIterPorc);
        vectorTiempoAO(i,:)= tiempos;
        vectorperf15porc(i,:)=perf15porc;
        vectorMejorPosAO(i)=Best_P(i);

    end



        MediaMejores=mean(max(fObj_pond')); %Es el promedio de los mejores
        MejorDeMejores=max(max(fObj_pond));
        mejorSTD = std(reshape(fObj_pond,[],1));
    

    
        desvEstandar = std(conv(:,end));  
        valorMayorProm = mean(conv(:,end));   
    
        desAOTimeSTD = std(vectorTiempoAO);  
        desAOTimeMean = mean(vectorTiempoAO);  
        
        aux=strcat("Prueba ACC_",num2str(pondAcc),"_y_GMEAN_",num2str(pondGmean),".mat");
        save(aux)

    %Guardar cada instancia de fconven la lista
    aquila_list{end+1} = conv;
    accuracy_list{end+1} = pondAcc;
    gmean_list{end+1} = pondGmean;
    cantIterPorc_list{end+1} = cantIterPorc;


    %Proceso de graficado
    
    %Convergencia de AO
    %x=1:cantIterPorc;
    %y=conv;
    %figure, boxplot(y,x),xlabel('N� Iteration');
    %ylabel('Performance');
    %cadAux=strcat("Aquila Optimizer's convergence in dataset ",entradaBD,...
    %    ", ","Accuracy: ",num2str(pondAcc)," and G-mean: ",num2str(pondGmean));
    %title(cadAux);
    %hold on; grid on; grid minor;
    

end

%devolver lista conv
conv_list = aquila_list;

%devolver lista accuracy
lista_accuracy = accuracy_list;

%devolver lista gmean
lista_gmean = gmean_list;

%devolver lista cantIterPorc
lista_cantIterPorc = cantIterPorc_list;
% Mostrar conv_list en la terminal
%disp('Convergence List:');
%disp(conv_list);
%disp(cantIterPorc);


end
