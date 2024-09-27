clear all
clc
close all

%entradaBD="diabetes2.dt";
entradaBD="UCICarduicography3ClassNorm.csv";
archivo=load(entradaBD);

%Proceso de normalizaci�n
tamano=size(archivo);
for i=1:tamano(2)-1
    aux=archivo(:,i);
    [aux,PS]=mapminmax(aux',-1,1);
    archivo(:,i)=aux';
end

%Dominio de las variables/ejes y n?mero de dimensiones
LB=1;
tamano=size(archivo);
UB=ceil(tamano(1)*0.8);
if(UB>15000)
    UB=15000; 
end

%N�mero de ?guilas y N?mero de iteraciones
N=10;

neuronas_ocultas=LB:1:UB;
tamaNeu=size(neuronas_ocultas);
C=2.^[-25:1:25];
tamaC=size(C);

porcentaje=(1/50)*100;
T = ceil((porcentaje*tamaNeu(2)*tamaC(2))/(100*N));
%T=35;

%UB=800;
Dim=2;

k=5;
particion = 1-1/k;

exac_testeo = zeros(k,length(neuronas_ocultas));
mg_testeo = zeros(k,length(neuronas_ocultas));
fObj_pond = zeros(k,length(neuronas_ocultas)); 

%Nuevo proceso
%k iteraciones
vectorTiempoExh = zeros(1,k);

%Son de dos dimensiones para trabajar con la regularizada
vectorMejorResExhPond = zeros(1,k);
vectorMejorPosExhPond = zeros(2,k);
vectorMejorResExhGmean = zeros(1,k);
vectorMejorPosExhGmean = zeros(2,k);
vectorMejorResExhAccuracy = zeros(1,k);
vectorMejorPosExhAccuracy = zeros(2,k);
% tbl=array2table(archivo(:,end-1));
% tbl.Y = archivo(:,end);
% 
% rng('default') % For reproducibility
% n = length(tbl.Y);
% 
% hpartition = cvpartition(n,'Holdout',0.3); % Nonstratified partition
% 
% idxTrain = training(hpartition);
% tblTrain = tbl(idxTrain,:);
% idxNew = test(hpartition);
% tblNew = tbl(idxNew,:);
% 
% c = cvpartition(archivo,"KFold",5);


xx=archivo(:,1:end-1);
yy=archivo(:,end);

% Supongamos que tienes un conjunto de datos representado por X (caracter�sticas) y y (etiquetas)
k = 5; % N�mero de folds
cv = cvpartition(yy, 'KFold', k); % Crea particiones k-fold estratificadas

for i = 1:k
    i
    % Separa los datos en conjuntos de entrenamiento y prueba
    test_indices = test(cv, i); % �ndices de prueba para el fold actual
    train_indices = training(cv, i); % �ndices de entrenamiento para el fold actual
    X_train = xx(train_indices, :);
    y_train = yy(train_indices);
    X_test = xx(test_indices, :);
    y_test = yy(test_indices);
    
    entrenamiento=horzcat(X_train, y_train);
    testeo=horzcat(X_test, y_test);
    
    entradas_entrenamiento=entrenamiento(:,1:end-1);
    salidas_entrenamiento=entrenamiento(:,end);
    entradas_testeo=testeo(:,1:end-1);
    salidas_testeo=testeo(:,end);
    
    %B�squeda exhaustiva  
    tic
    for ii=1:length(neuronas_ocultas)
        for jj=1:length(C)
            [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELMregu(entradas_entrenamiento, salidas_entrenamiento,entradas_testeo,...
                    salidas_testeo,1, neuronas_ocultas(ii), 'sig', C(jj));
            
            exac_testeo(i,ii,jj) = TestingAccuracy;
            mg_testeo(i,ii,jj) = test_gmean;
            fObj_pond(i,ii,jj) = TestingAccuracy*0.5 + test_gmean*0.5;
            
            if(vectorMejorResExhPond(i)<fObj_pond(i,ii,jj))
                vectorMejorResExhPond(i)=fObj_pond(i,ii,jj);
                vectorMejorPosExhPond(1,i)=neuronas_ocultas(ii);
                vectorMejorPosExhPond(2,i)=C(jj);
            end
            
            if(vectorMejorResExhGmean(i)<mg_testeo(i,ii,jj))
                vectorMejorResExhGmean(i)=mg_testeo(i,ii,jj);
                vectorMejorPosExhGmean(1,i)=neuronas_ocultas(ii);
                vectorMejorPosExhGmean(2,i)=C(jj);
            end
            
            if(vectorMejorResExhAccuracy(i)<exac_testeo(i,ii,jj))
                vectorMejorResExhAccuracy(i)=exac_testeo(i,ii,jj);
                vectorMejorPosExhAccuracy(1,i)=neuronas_ocultas(ii);
                vectorMejorPosExhAccuracy(2,i)=C(jj);
            end
        end
    end
    vectorTiempoExh(i) = toc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gr�fico de la b�squeda exhaustiva%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanExact=mean(exac_testeo,1);
meanMg=mean(mg_testeo,1);
meanProm=mean(fObj_pond,1);

tamaAcc=size(meanExact);
tamaMg=size(meanMg);
tamaProm=size(meanProm);

Xa=1:tamaAcc(2);
Ya=1:tamaAcc(3);

%Accuracy
[X,Y] = meshgrid(Xa,Ya);
Z=squeeze(meanExact(1,:,:));
figure, surf(X,Y,Z');
title('Accuracy');
filename=strcat("Exhaustive Search - Accuracy - CardioCotography");
savefig(filename);

%G-Mean
[X,Y] = meshgrid(Xa,Ya);
Z=squeeze(meanMg(1,:,:));
figure, surf(X,Y,Z');
title('G-Mean');
filename=strcat("Exhaustive Search - G-Mean - CardioCotography");
savefig(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Gr�fico de calor Accuracy%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanExact = mean(exac_testeo, 1);
tamaAcc = size(meanExact);

Xa = neuronas_ocultas(1:tamaAcc(2));
Ya = C(tamaAcc(3):-1:1);

% Invertir el eje Y
Ya_invertido = flip(Ya);

% Crear la malla invertida para representar el mapa de calor
[X, Y] = meshgrid(Xa, Ya_invertido);

Z = squeeze(meanExact(1, :, :));

% Crear el gr�fico de mapa de calor 2D
h = figure;
imagesc(Xa, Ya_invertido, Z');  % Usar Ya_invertido en lugar de Ya
colorbar;  % Mostrar la barra de colores
title('Accuracy Heatmap');
xlabel('N� Neural');
ylabel('C');

% Invertir el eje Y en la visualizaci�n del gr�fico
set(gca, 'YDir', 'normal');

filename = "Exhaustive Search - Accuracy Heatmap";
savefig(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Gr�fico de calor G-Mean%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanGmean = mean(mg_testeo, 1);
tamaAcc = size(meanGmean);

Xa = neuronas_ocultas(1:tamaAcc(2));
Ya = C(tamaAcc(3):-1:1);

% Invertir el eje Y
Ya_invertido = flip(Ya);

% Crear la malla invertida para representar el mapa de calor
[X, Y] = meshgrid(Xa, Ya_invertido);

Z = squeeze(meanGmean(1, :, :));

% Crear el gr�fico de mapa de calor 2D
h = figure;
imagesc(Xa, Ya_invertido, Z');  % Usar Ya_invertido en lugar de Ya
colorbar;  % Mostrar la barra de colores
title('G-Mean Heatmap');
xlabel('N� Neural');
ylabel('C');

% Invertir el eje Y en la visualizaci�n del gr�fico
set(gca, 'YDir', 'normal');

filename = "Exhaustive Search - G-Mean Heatmap";
savefig(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save("WorkspaceConExhaus.mat")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Inicializaci?n de variables necesarias
Best_FF=zeros(1,k);
Best_P=zeros(k,Dim);
conv=zeros(k,T);
convAcc=zeros(k,T);
convGmean=zeros(k,T);
conv_pond=zeros(k,T);
conv_prom=zeros(k,T);

%Proceso ABC FULL OBL
vectorTiempoABC = zeros(2,k,T);
vectorConvPondABC = zeros(2,k,T);
vectorConvAccuracyABC = zeros(2,k,T);
vectorConvGmeanABC = zeros(2,k,T);
vectorConvPromABC = zeros(2,k,T);
vectorMejorPosABC = zeros(2,k, Dim);

vectorTiempoABCINITOBL = zeros(2,k,T);
vectorConvPondABCINITOBL = zeros(2,k,T);
vectorConvAccuracyABCINITOBL = zeros(2,k,T);
vectorConvGmeanABCINITOBL = zeros(2,k,T);
vectorConvPromABCINITOBL = zeros(2,k,T);
vectorMejorPosABCINITOBL = zeros(2,k, Dim);

vectorTiempoABCOBL = zeros(2,k,T);
vectorConvPondABCOBL = zeros(2,k,T);
vectorConvAccuracyABCOBL = zeros(2,k,T);
vectorConvGmeanABCOBL = zeros(2,k,T);
vectorConvPromABCOBL = zeros(2,k,T);
vectorMejorPosABCOBL = zeros(2,k, Dim);

vectorTiempoABCFULLOBL = zeros(2,k,T);
vectorConvPondABCFULLOBL = zeros(2,k,T);
vectorConvAccuracyABCFULLOBL = zeros(2,k,T);
vectorConvGmeanABCFULLOBL = zeros(2,k,T);
vectorConvPromABCFULLOBL = zeros(2,k,T);
vectorMejorPosABCFULLOBL = zeros(2,k, Dim);

vectorTiempoABCPHIADBOBLREFLECT = zeros(2,k,T);
vectorConvPondABCPHIADBOBLREFLECT = zeros(2,k,T);
vectorConvAccuracyABCPHIADBOBLREFLECT = zeros(2,k,T);
vectorConvGmeanABCPHIADBOBLREFLECT = zeros(2,k,T);
vectorConvPromABCPHIADBOBLREFLECT = zeros(2,k,T);
vectorMejorPosABCPHIADBOBLREFLECT = zeros(2,k, Dim);

aux=1;

for macroCiclo=0:1:1
    macroCiclo
    pondAcc = macroCiclo;
    pondGmean = 1 - pondAcc;
    %cv = cvpartition(y, 'KFold', k);
    clear test_indices
    clear train_indices
    clear X_train
    clear y_train
    clear X_test
    clear y_test
    
    %k iteraciones
    for i=1:k
        macroCiclo
        %Configuraci�n est�ndar para ambos m�todos
        test_indices = test(cv, i); % �ndices de prueba para el fold actual
       
        train_indices = training(cv, i); % �ndices de entrenamiento para el fold actual
        X_train = xx(train_indices, :);
        y_train = yy(train_indices);
        X_test = xx(test_indices, :);
        y_test = yy(test_indices);
        
        entrenamiento=horzcat(X_train, y_train);
        testeo=horzcat(X_test, y_test);
        
        %Artificial Bee Colony
        [Best_FF,Best_P,conv_prom,convAcc,convGmean,tiempos,conv_pond]=ABCoriginal(N,T,Dim,entrenamiento,...
           testeo,pondAcc,pondGmean,neuronas_ocultas,C);
        
        vectorConvPondABC(aux, i, :) = conv_pond;
        vectorConvPromABC(aux, i, :) = conv_prom;
        vectorConvAccuracyABC(aux, i, :) = convAcc;
        vectorConvGmeanABC(aux, i, :) = convGmean;
        
        vectorTiempoABC(aux, i, :)= tiempos;
        vectorMejorPosABC(aux, i, :)=Best_P;
        
        %Artificial Bee Colony INIT OBL
        [Best_FF,Best_P,conv_prom,convAcc,convGmean,tiempos,conv_pond]=ABCoriginalFormulasAdaptativas(N,T,Dim,entrenamiento,...
            testeo,pondAcc,pondGmean,neuronas_ocultas,C);
        vectorConvPondABCINITOBL(aux, i, :) = conv_pond;
        vectorConvPromABCINITOBL(aux, i, :) = conv_prom;
        vectorConvAccuracyABCINITOBL(aux, i, :) = convAcc;
        vectorConvGmeanABCINITOBL(aux, i, :) = convGmean;
        
        vectorTiempoABCINITOBL(aux, i, :)= tiempos;
        vectorMejorPosABCINITOBL(aux, i, :)=Best_P;
        
        %Artificial Bee Colony OBL
        [Best_FF,Best_P,conv_prom,convAcc,convGmean,tiempos,conv_pond]=ABCoriginalFormuAdapOBL(N,T,Dim,entrenamiento,...
            testeo,pondAcc,pondGmean,neuronas_ocultas,C);
        vectorConvPondABCOBL(aux, i, :) = conv_pond;
        vectorConvPromABCOBL(aux, i, :) = conv_prom;
        vectorConvAccuracyABCOBL(aux, i, :) = convAcc;
        vectorConvGmeanABCOBL(aux, i, :) = convGmean;
        
        vectorTiempoABCOBL(aux, i, :)= tiempos;
        vectorMejorPosABCOBL(aux, i, :)=Best_P;
        
        %Artificial Bee Colony FULL OBL
        [Best_FF,Best_P,conv_prom,convAcc,convGmean,tiempos,conv_pond]=ABCFULLOBL(N,T,Dim,entrenamiento,...
            testeo,pondAcc,pondGmean,neuronas_ocultas,C);
        vectorConvPondABCFULLOBL(aux, i, :) = conv_pond;
        vectorConvPromABCFULLOBL(aux, i, :) = conv_prom;
        vectorConvAccuracyABCFULLOBL(aux, i, :) = convAcc;
        vectorConvGmeanABCFULLOBL(aux, i, :) = convGmean;
        
        vectorTiempoABCFULLOBL(aux, i, :)= tiempos;
        vectorMejorPosABCFULLOBL(aux, i, :)=Best_P;
        
        
        %Artificial Bee Colony PHI ADP OBL REFLECT
        [Best_FF,Best_P,conv_prom,convAcc,convGmean,tiempos,conv_pond]=ABCoriginalFormuAdapOBLBondReflect(N,T,Dim,entrenamiento,...
            testeo,pondAcc,pondGmean,neuronas_ocultas,C);
        vectorConvPondABCPHIADBOBLREFLECT(aux, i, :) = conv_pond;
        vectorConvPromABCPHIADBOBLREFLECT(aux, i, :) = conv_prom;
        vectorConvAccuracyABCPHIADBOBLREFLECT(aux, i, :) = convAcc;
        vectorConvGmeanABCPHIADBOBLREFLECT(aux, i, :) = convGmean;
        
        vectorTiempoABCPHIADBOBLREFLECT(aux, i, :)= tiempos;
        vectorMejorPosABCPHIADBOBLREFLECT(aux, i, :)=Best_P;     
    end

    aux=aux+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inicio del segundo conjunto de gr�ficos%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure;
tama = size(vectorConvGmeanABC(1, :, :));
x = 1:T;

yaux1 = mean(vectorConvAccuracyABC(2, :, :),2);
yaux2 = mean(vectorConvAccuracyABCINITOBL(2, :, :),2);
yaux3 = mean(vectorConvAccuracyABCOBL(2, :, :),2);
yaux4 = mean(vectorConvAccuracyABCPHIADBOBLREFLECT(2, :, :),2);
yaux5 = mean(vectorConvAccuracyABCFULLOBL(2, :, :),2);


subplot(1, 2, 1);

y1=zeros(1,tama(3));
y2=zeros(1,tama(3));
y3=zeros(1,tama(3));
y4=zeros(1,tama(3));
y5=zeros(1,tama(3));

for m=1:tama(3)
    y1(1,m)=yaux1(1,1,m);
    y2(1,m)=yaux2(1,1,m);
    y3(1,m)=yaux3(1,1,m);
    y4(1,m)=yaux4(1,1,m);
    y5(1,m)=yaux5(1,1,m);
end

p1 = plot(x, y1, 'm', x, y2, 'b', x, y3, 'g', x, y4, 'r', x, y5, 'c');

hold on;
plot(x, ones(size(x)) * mean(vectorMejorResExhAccuracy), '--k');   


[max_y0, idx_y0] = max(mean(vectorMejorResExhAccuracy));
text(x(idx_y0), max_y0, strcat(num2str(round(max_y0,3))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'k');


%plot(x, ones(size(x)) * max(vectorMejorResExhAccuracy), '--y');  
%plot(x, ones(size(x)) * mean(vectorMejorResExhAccuracy), '--b');   

[max_y1, idx_y1] = max(y1);
[max_y2, idx_y2] = max(y2);
[max_y3, idx_y3] = max(y3);
[max_y4, idx_y4] = max(y4);
[max_y5, idx_y5] = max(y5);

% Marca los puntos m?s altos con un c?rculo
plot(x(idx_y1), max_y1, 'mo', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y2), max_y2, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y3), max_y3, 'go', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y4), max_y4, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y5), max_y5, 'co', 'MarkerSize', 10, 'LineWidth', 2);

text(x(idx_y1), max_y1, strcat("(",num2str(neuronas_ocultas(x(idx_y1))),",",num2str(round(max_y1,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'm');
text(x(idx_y2), max_y2, strcat("(",num2str(neuronas_ocultas(x(idx_y2))),",",num2str(round(max_y2,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'b');
text(x(idx_y3), max_y3, strcat("(",num2str(neuronas_ocultas(x(idx_y3))),",",num2str(round(max_y3,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'g');
text(x(idx_y4), max_y4, strcat("(",num2str(neuronas_ocultas(x(idx_y4))),",",num2str(round(max_y4,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'r');
text(x(idx_y5), max_y5, strcat("(",num2str(neuronas_ocultas(x(idx_y5))),",",num2str(round(max_y5,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'c');

grid on;
%scatter((x(idx_y1)), y1(x(idx_y1)) , 120, 'r', 'filled');
%scatter((x(idx_y2)), y2(x(idx_y2)) , 120, 'b', 'filled');
%text(neuronas_ocultas(x(idx_y1)), y1(x(idx_y1)), strcat("(",num2str(neuronas_ocultas(x(idx_y1))),",",num2str(round(y1(x(idx_y1)),3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'r');
%text(neuronas_ocultas(x(idx_y2)), y2(x(idx_y2)), strcat("(",num2str(neuronas_ocultas(x(idx_y2))),",",num2str(round(y2(x(idx_y2)),3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'b');

%Configura el t�tulo, etiquetas y leyenda
title('Objetive Function: Accuracy');
xlabel('N� Iteration');
ylabel('Performance');

legend('Accuracy (ABC)', 'Accuracy (Adaptative Phi ABC)', 'Accuracy (Adaptative Phi OBL ABC)','Accuracy (Adaptative Phi OBL Reflect ABC)', 'Accuracy (FULL-OBL ABC)', 'Accuracy (Mean Exhaustive)', 'Accuracy (Best ABC)', 'Accuracy (Best Adaptative Phi ABC)', 'Accuracy (Best Adaptative Phi OBL ABC)','Accuracy (Best Phi OBL Reflect ABC)' ,'Accuracy (Best FULL-OBL ABC)', 'Location', 'southeast');
set(gca, 'FontSize', 12); % Tama�o de fuente para los ejes
set(findall(gcf,'type','text'),'FontSize',12); % Tama�o de fuente para el resto de texto


%Sugr�fico 2
yaux1 = mean(vectorConvGmeanABC(1, :, :),2);
yaux2 = mean(vectorConvGmeanABCINITOBL(1, :, :),2);
yaux3 = mean(vectorConvGmeanABCOBL(1, :, :),2);
yaux4 = mean(vectorConvGmeanABCPHIADBOBLREFLECT(1, :, :),2);
yaux5 = mean(vectorConvGmeanABCFULLOBL(1, :, :),2);

subplot(1, 2, 2);

y1=zeros(1,tama(3));
y2=zeros(1,tama(3));
y3=zeros(1,tama(3));
y4=zeros(1,tama(3));
y5=zeros(1,tama(3));

for m=1:tama(3)
    y1(1,m)=yaux1(1,1,m);
    y2(1,m)=yaux2(1,1,m);
    y3(1,m)=yaux3(1,1,m);
    y4(1,m)=yaux4(1,1,m);
    y5(1,m)=yaux5(1,1,m);
end
p1 = plot(x, y1, 'm', x, y2, 'b', x, y3, 'g', x, y4, 'r', x, y5, 'c');

hold on;
plot(x, ones(size(x)) * mean(vectorMejorResExhGmean), '--k');
[max_y0, idx_y0] = max(mean(vectorMejorResExhGmean));
text(x(idx_y0), max_y0, strcat(num2str(round(max_y0,3))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'k');



%plot(x, ones(size(x)) * max(vectorMejorResExhAccuracy), '--y');  
%plot(x, ones(size(x)) * mean(vectorMejorResExhAccuracy), '--b');   
    
[max_y1, idx_y1] = max(y1);
[max_y2, idx_y2] = max(y2);
[max_y3, idx_y3] = max(y3);
[max_y4, idx_y4] = max(y4);
[max_y5, idx_y5] = max(y5);

% Marca los puntos m?s altos con un c?rculo
plot(x(idx_y1), max_y1, 'mo', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y2), max_y2, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y3), max_y3, 'go', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y4), max_y4, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
plot(x(idx_y5), max_y5, 'co', 'MarkerSize', 10, 'LineWidth', 2);

text(x(idx_y1), max_y1, strcat("(",num2str(neuronas_ocultas(x(idx_y1))),",",num2str(round(max_y1,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'm');
text(x(idx_y2), max_y2, strcat("(",num2str(neuronas_ocultas(x(idx_y2))),",",num2str(round(max_y2,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'b');
text(x(idx_y3), max_y3, strcat("(",num2str(neuronas_ocultas(x(idx_y3))),",",num2str(round(max_y3,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'g');
text(x(idx_y4), max_y4, strcat("(",num2str(neuronas_ocultas(x(idx_y4))),",",num2str(round(max_y4,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'r');
text(x(idx_y5), max_y5, strcat("(",num2str(neuronas_ocultas(x(idx_y5))),",",num2str(round(max_y5,3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'c');

grid on;
%scatter((x(idx_y1)), y1(x(idx_y1)) , 120, 'r', 'filled');
%scatter((x(idx_y2)), y2(x(idx_y2)) , 120, 'b', 'filled');
%text(neuronas_ocultas(x(idx_y1)), y1(x(idx_y1)), strcat("(",num2str(neuronas_ocultas(x(idx_y1))),",",num2str(round(y1(x(idx_y1)),3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'r');
%text(neuronas_ocultas(x(idx_y2)), y2(x(idx_y2)), strcat("(",num2str(neuronas_ocultas(x(idx_y2))),",",num2str(round(y2(x(idx_y2)),3)),")"), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'b');

%Configura el t�tulo, etiquetas y leyenda
title('Objetive Function: G-Mean');
xlabel('N� Iteration');
ylabel('Performance');

legend('G-Mean (ABC)', 'G-Mean (Adaptative Phi ABC)', 'G-Mean (Adaptative Phi OBL ABC)','G-Mean (Adaptative Phi OBL Reflect ABC)', 'G-Mean (FULL-OBL ABC)',...
    'G-Mean (Mean Exhaustive)', 'G-Mean (Best ABC)', 'G-Mean (Best Adaptative Phi ABC)', 'G-Mean (Best Adaptative Phi OBL ABC)','G-Mean (Best Phi OBL Reflect ABC)' ,...
    'G-Mean (Best FULL-OBL ABC)', 'Location', 'southeast');

set(gca, 'FontSize', 12); % Tama�o de fuente para los ejes
set(findall(gcf,'type','text'),'FontSize',12); % Tama�o de fuente para el resto de texto



%%%%%%%%%%%%%%%%%%%%%%%%
%Boxplot de los tiempos%
%%%%%%%%%%%%%%%%%%%%%%%%

%Tiempos Accuracy
y1=zeros(1,5);
y2=zeros(1,5);
y3=zeros(1,5);
y4=zeros(1,5);
y5=zeros(1,5);
y6=zeros(1,5);

for iii=1:5
    y1(1,iii)=vectorTiempoABC(1,iii,end);
    y2(1,iii)=vectorTiempoABCFULLOBL(1,iii,end);
    y3(1,iii)=vectorTiempoABCINITOBL(1,iii,end);
    y4(1,iii)=vectorTiempoABCOBL(1,iii,end);
    %y5(1,iii)=vectorTiempoABCPHIADBOBLREFLECT(2,iii,end);
    
    y6(1,iii)=vectorTiempoExh(1,iii);
end

y = zeros(5, 5);
for iii = 1:5
    y(:, iii) = [y1(1,iii);
                 y2(1,iii);
                 y3(1,iii);
                 y4(1,iii);
                 y6(1,iii)];
end

figure;
hold on;
grid on;
ylabel('Time (Seconds)');
boxplot(y', 'Labels', {'Base ABC', 'FOBL-ABC', 'AEP-ABC', 'AEP-OBL ABC','Exhaustive Search'});
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Boxplot de los tiempos incluido el exhaustivo%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definici�n de los datos
y = zeros(6,5);
for iii=1:5
    y(:, iii) = [y1(1,iii);
                 y2(1,iii);
                 y3(1,iii);
                 y4(1,iii);
                 y5(1,iii);
                 y6(1,iii)];
end
figure, boxplot(y', 'Labels', {'ABC', 'Adaptative Phi ABC', 'Tiempo Adaptative Phi OBL ABC', 'Tiempo Adaptative Phi OBL REFLECT ABC', 'FULL-OBL ABC', 'Exhaustive'});


%C�digo para generaci�n de la informaci�n de la tabla

%Tiempos:
RESTiempoEuxh=round(mean(vectorTiempoExh),3);
RESTiempoEuxhSTD=round(std(vectorTiempoExh),3);
sprintf("Resultado tiempo Exhaustivo: %g +- %g",RESTiempoEuxh,RESTiempoEuxhSTD);

RESTiempoABCAcc=round(mean(vectorTiempoABC(2,:,T)),3)
RESTiempoABCAccSTD=round(std(vectorTiempoABC(2,:,T)),3)
sprintf("Porcentaje Accuracy");
PorcTimeAcc=100*(RESTiempoABCAcc/RESTiempoEuxh)

RESTiempoABCGMean=round(mean(vectorTiempoABC(1,:,T)),3)
RESTiempoABCGMeanSTD=round(std(vectorTiempoABC(1,:,T)),3)
sprintf("Porcentaje G-Mean");
PorcTimeGMean=100*(RESTiempoABCGMean/RESTiempoEuxh)

%Performance
sprintf("Resultados Accuracy");
RESPerfEuxhAcc=round(mean(vectorMejorResExhAccuracy),3)
RESPerfEuxhAccSTD=round(std(vectorMejorResExhAccuracy),3)
RESABCACC=round(mean(vectorConvAccuracyABC(2,:,T)),3)
RESABCACCSTD=round(std(vectorConvAccuracyABC(2,:,T)),3)
PorcACC=100*(RESABCACC/RESPerfEuxhAcc)

sprintf("Resultados G-Mean");
RESPerfEuxhGmean=round(mean(vectorMejorResExhGmean),3)
RESPerfEuxhGmeanSTD=round(std(vectorMejorResExhGmean),3)
RESABCGmean=round(mean(vectorConvGmeanABC(1,:,T)),3)
RESABCGmeanSTD=round(std(vectorConvGmeanABC(1,:,T)),3)
PorcGMean=100*(RESABCGmean/RESPerfEuxhGmean)

save("Workspace Reflect menos itera.mat")