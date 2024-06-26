clear
clc
close all
load diabetes2.dt;
%entrenamiento=diabetes2(1:round(length(diabetes2)/2),:);
%testeo=diabetes2(round(length(diabetes2)/2)+1:end,:);

%Ver despu�s con Amelia
%entrenamiento_90=diabetes2(round(length(diabetes2)/2)+1:end,:);
%validacion=diabetes2(round(length(diabetes2)/2)+1:end,:);
%%%%%%%%%%%%%%
%Algoritmo AO%
%%%%%%%%%%%%%%

N=10;
T=25;
LB=1;
UB=700;
Dim=1;

Best_FF=zeros(5);
Best_P=zeros(5,Dim);
conv=zeros(5,T);

tic
for i=1:5
    nale=randperm(size(diabetes2,1));
    bdd=diabetes2(nale,:);
    entrenamiento=bdd(1:round(length(bdd)*0.8),:);
    testeo=bdd(round(length(bdd)*0.8)+1:end,:);
    [Best_FF(i,:),Best_P(i,:),conv(i,:)]=AO_MEAN_PERF(N,T,LB,UB,Dim,entrenamiento,testeo);
end
t1=toc;

x=1:T;
y=conv;

figure, boxplot(y,x),xlabel('N� Iteration');
ylabel('Performance');
title("Aquila Optimizer's convergence");
hold on; grid on; grid minor;

%plot(x,y,'Color','g','LineWidth',2);

%%%%%%%%%%%%%%%%%%%%%
%B�squeda Exhaustiva%
%%%%%%%%%%%%%%%%%%%%%
neuronas_ocultas=LB:UB;
for i=1:5
    for ii=1:length(neuronas_ocultas)
        nale=randperm(size(diabetes2,1));
        bdd=diabetes2(nale,:);
        entrenamiento=bdd(1:round(length(bdd)*0.8),:);
        testeo=bdd(round(length(bdd)*0.8)+1:end,:);
        [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1,...
            neuronas_ocultas(ii), 'sig');
        tiempo_entrenamiento(i,ii)=TrainingTime;
        tiempo_testeo(i,ii)=TestingTime;
        exac_entrenamiento(i,ii)=TrainingAccuracy;
        exac_testeo(i,ii)=TestingAccuracy;
        mg_testeo(i,ii)=test_gmean;
        mezcla_fobjetivos(i,ii)=(TestingAccuracy+test_gmean)/2;
    end
end
t2=toc;
mejor=max(max(mezcla_fobjetivos));
x=neuronas_ocultas;
y=mean(mezcla_fobjetivos);

figure, plot(x,y);hold on; grid on; grid minor;
xlabel('N� hidden layers');
ylabel('Performance');
title("Exhaustive Search");


valorMayorProm = mean(conv(:,end));
fprintf("El m�ximo global es %f\n",mejor);
fprintf("El valor promedio mayor de AO es %f\n",valorMayorProm);
res = round((valorMayorProm/mejor)*100,1);
fprintf("El rendimiento es un %g porciento del �ptimo global secuencial\n",res);
fprintf("El tiempo es un %g porciento del tiempo secuencial\n",(t1/t2)*100);
