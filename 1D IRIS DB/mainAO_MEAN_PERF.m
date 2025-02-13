clear
clc
close all

entradaBD="iris.dt";

archivo=load(entradaBD);
%entrenamiento=diabetes2(1:round(length(diabetes2)/2),:);
%testeo=diabetes2(round(length(diabetes2)/2)+1:end,:);

%Ver despu�s con Amelia
%entrenamiento_90=diabetes2(round(length(diabetes2)/2)+1:end,:);
%validacion=diabetes2(round(length(diabetes2)/2)+1:end,:);

%La suma de las ponderaciones de Accuracy y Gmean deben sumar 1
modoPonderado = true;
if(modoPonderado==true)
    inicio=0;
    fin=1;
else
    inicio = 0.5;
    fin = 0.5;
end

%N�mero de �guilas y N�mero de iteraciones
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
    
    %Convergencia de b�squeda exhaustiva 
    x=neuronas_ocultas;
    y=mean(fObj_pond(:,:));
    figure, plot(x,y);hold on; grid on; grid minor;
    xlabel('N� Neurals');
    ylabel('Performance');
    cadAux=strcat("Exhaustive Search in dataset ",entradaBD,...
        ", ","Accuracy: ",num2str(pondAcc)," and G-mean: ",num2str(pondGmean));
    title(cadAux);
        
        
%     cadena=strcat("salida ",num2str(pondAcc),"_",num2str(pondGmean),".txt");
%     fileID = fopen(cadena,'w');
%     fprintf(fileID,"Ejecuci�n con ACC ponderado a %g y Gmean ponderado a %g\n",pondAcc, pondGmean);
%     fprintf(fileID,"Tiempo AO: %g con std: %g\n",desAOTimeMean,desAOTimeSTD);
%     fprintf(fileID,"El porcentaje del tiempo respecto a la b�squeda exhaustiva es %g\n",(desAOTimeMean*100)/mean(mean(vectorTiempoExh)));
%     fprintf(fileID,"Performance AO: %g con std: %g\n",valorMayorProm,desvEstandar);
%     res = round((valorMayorProm/mejor)*100,1);
%     fprintf(fileID,"El rendimiento es un %g porciento del �ptimo global secuencial\n",res);
%     fprintf(fileID,"Optimo global promedio: %g\n",mejor);
%     fprintf(fileID,"Optimo global STD: %g\n",mejorSTD);
%     fprintf(fileID,"Matriz tiempo AO: %g\n",vectorTiempoAO);
%     fprintf(fileID,"Matriz performance AO: %g\n",vectorperf15porc);
%     fprintf(fileID,"Los 5 mejores posiciones del exhaustivo son %g\n",vectorMejorPosExh);    
%     fprintf(fileID,"Los 5 mejores performance del exhaustivo son %g\n",vectorMejorPosExh);
%     fprintf(fileID,"Los 5 mejores posiciones del AO son %g\n",conv(:,end));
%     fprintf(fileID,"Los 5 mejores performance del AO son %g\n",vectorMejorPosAO);
%     fclose(fileID);
    
%     fprintf("El m�ximo global es %f\n",mejor);
%     fprintf("El valor promedio mayor de AO es %g con desviaci�n est�ndar %g\n",valorMayorProm,desvEstandar);
%     res = round((valorMayorProm/mejor)*100,1);
%     fprintf("El rendimiento es un %g porciento del �ptimo global secuencial\n",res);
%     fprintf("Tiempo AO medio %g\n", mean(vectorTiempoAO)/repeticiones);
%     fprintf("Tiempo b�squeda exhaustiva medio %g\n", mean(vectorTiempoExh)/repeticiones);
%     fprintf("El tiempo es un %g porciento del tiempo secuencial\n\n\n",(tiempoAO/tiempoSec)*100);
%     
end
