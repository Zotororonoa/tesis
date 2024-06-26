
function [Best_FF,Best_P,conv,conv_Accuracy,conv_GMean,tiempos,perf15porc]=AO_MEAN_PERF(N,T,LB,UB,Dim,entrenamiento,testeo, pondAcc, pondGmean, cantIterPorc)
    tic
    T=cantIterPorc;
    tiempos=zeros(1,cantIterPorc); %Matriz que contiene los tiempos, mejorar la inclusi�n de repeticiones
    perf15porc=zeros(1,cantIterPorc);
    
    if(Dim==1) 
        Forbidden = zeros(UB(1)-LB(1)+1,1);
    else
        Forbidden = zeros(UB(1),UB(2));
    end

    Best_P=zeros(1,Dim);
    Best_FF=0;
    conv=zeros(1,T);
    conv_Accuracy=zeros(1,T);
    conv_GMean=zeros(1,T);
    
    %Genera una poblaci�n de �guilas en posiciones aleatorias distintas
    [X,Forbidden]=initialization(N,Dim,UB,LB,Forbidden); 
    Xnew=X; %Vector que almacena la soluci�n candidata actual de cada �guila
    Ffun=zeros(1,size(X,1));
    Ffun_new=zeros(1,size(Xnew,1));

    t=1;
    alpha=0.1;
    delta=0.1;
    
    while t<cantIterPorc+1        %T+1
        for  i=1:size(X,1)
            %Aqu� se limitan los elementos que exceden los bordes.
            F_UB=X(i,:)>UB;
            F_LB=X(i,:)<LB;
            X(i,:)=round((X(i,:).*(~(F_UB+F_LB)))+UB.*F_UB+LB.*F_LB);
            
            [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1, X(i,:), 'sig');
            Ffun(1,i)=TestingAccuracy*pondAcc + test_gmean*pondGmean;
            
            if Ffun(1,i)>Best_FF
                BestAccuracy=TestingAccuracy;
                BestGMean=test_gmean;
                Best_FF=Ffun(1,i);
                Best_P=X(i,:);
            end
        end
    
        G2=2*rand()-1; % Eq. (16)
        G1=2*(1-(t/T));  % Eq. (17)
        to = 1:Dim;
        u = .0265;
        r0 = 10;
        r = r0 +u*to;
        omega = .005;
        phi0 = 3*pi/2;
        phi = -omega*to+phi0;
        x = r .* sin(phi);  % Eq. (9)
        y = r .* cos(phi); % Eq. (10)
        QF=t^((2*rand()-1)/(1-T)^2); % Eq. (15)
        %-------------------------------------------------------------------------------------
        for i=1:size(X,1)
            if t<=(2/3)*T
                
                %B�squeda de exploraci�n expandida
                if rand <0.5 
                    bandera=true;
                    contador=0;
                    while(bandera==true)
                        %Acotaci�n Amelia: la mitad de las veces las
                        %aguilas tienden a moverse hacia o en contra del
                        %mejor global.
                        
                        %La media podr�a mejorarse para ejes de muy
                        %distinto dominio.
                        posAux=round(Best_P(1,:)*(1-t/T)+(mean(X(i,:))-Best_P(1,:))*rand()); % Eq. (3) and Eq. (4)
                        
                        F_UB=posAux>UB;
                        F_LB=posAux<LB;
                        posAux=round((posAux.*(~(F_UB+F_LB)))+UB.*F_UB+LB.*F_LB);
                        
                        res=comprueba_prohibido(posAux,Forbidden, Dim);
                        if(res==true)
                            Xnew(i,:) = posAux;
                            Forbidden(Xnew(i,:))=1;
                            bandera=false;
                        end
                        contador = contador + 1;
                        if(contador>5)
                            [Xnew(i,:), Forbidden]=initialization(1,Dim,UB,LB,Forbidden);
                            bandera=false;
                        end
                    end
                    
                    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1,Xnew(i,:), 'sig');
                 
                    Ffun_new(1,i)=TestingAccuracy*pondAcc + test_gmean*pondGmean;
                    if Ffun_new(1,i)>Ffun(1,i)
                        X(i,:)=Xnew(i,:);
                        Ffun(1,i)=Ffun_new(1,i);
                    end
                else
                    bandera=true;
                    contador=0;
                    while(bandera==true)
                        posAux=round(Best_P(1,:)*(1-t/T)+(mean(X(i,:))-Best_P(1,:))*rand()); % Eq. (3) and Eq. (4)
                        
                        F_UB=posAux>UB;
                        F_LB=posAux<LB;
                        posAux=round((posAux.*(~(F_UB+F_LB)))+UB.*F_UB+LB.*F_LB);
                        
                        res=comprueba_prohibido(posAux,Forbidden, Dim);
                        if(res==true)
                            Xnew(i,:) = posAux;
                            Forbidden(Xnew(i,:))=1;
                            bandera=false;
                        end
                        contador = contador + 1;
                        if(contador>5)
                            [Xnew(i,:), Forbidden]=initialization(1,Dim,UB,LB,Forbidden);
                            bandera=false;
                        end
                    end
                                        
                    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1,Xnew(i,:), 'sig');
                    Ffun_new(1,i)=TestingAccuracy*pondAcc + test_gmean*pondGmean;
                    
                    if Ffun_new(1,i)>Ffun(1,i)
                        X(i,:)=Xnew(i,:);
                        Ffun(1,i)=Ffun_new(1,i);
                    end
                end
                %-------------------------------------------------------------------------------------
            else
                if rand<0.5
                    %Exploraci�n estrecha
                    bandera=true;
                    contador=0;
                    while(bandera==true)
                        posAux=round((Best_P(1,:)-mean(X))*alpha-rand+((UB-LB)*rand+LB)*delta);   % Eq. (13)
                        
                        F_UB=posAux>UB;
                        F_LB=posAux<LB;
                        posAux=round((posAux.*(~(F_UB+F_LB)))+UB.*F_UB+LB.*F_LB);
                        
                        res=comprueba_prohibido(posAux,Forbidden, Dim);
                        if(res==true)
                            Xnew(i,:) = posAux;
                            Forbidden(Xnew(i,:))=1;
                            bandera=false;
                        end
                        contador = contador + 1;
                        if(contador>5)
                            [Xnew(i,:), Forbidden]=initialization(1,Dim,UB,LB,Forbidden);
                            bandera=false;
                        end
                    end

                    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1,Xnew(i,:), 'sig');
                    
                    Ffun_new(1,i)=TestingAccuracy*pondAcc + test_gmean*pondGmean;
                    
                    if Ffun_new(1,i)>Ffun(1,i)
                        X(i,:)=Xnew(i,:);
                        Ffun(1,i)=Ffun_new(1,i);
                    end
                else
                    bandera=true;
                    contador=0;
                    while(bandera==true)
                        posAux=round(QF*Best_P(1,:)-(G2*X(i,:)*rand)-G1.*Levy(Dim)+rand*G2); % Eq. (14)
                        
                        F_UB=posAux>UB;
                        F_LB=posAux<LB;
                        posAux=round((posAux.*(~(F_UB+F_LB)))+UB.*F_UB+LB.*F_LB);
                        
                        res=comprueba_prohibido(posAux,Forbidden, Dim);
                        if(res==true)
                            Xnew(i,:) = posAux;
                            Forbidden(Xnew(i,:))=1;
                            bandera=false;
                        end
                        contador = contador + 1;
                        if(contador>5)
                            [Xnew(i,:), Forbidden]=initialization(1,Dim,UB,LB,Forbidden);
                            bandera=false;
                        end
                    end
                                        
                    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, test_gmean]=ELM(entrenamiento, testeo, 1,Xnew(i,:), 'sig');
                    
                    Ffun_new(1,i)=TestingAccuracy*pondAcc + test_gmean*pondGmean;
                    
                    if Ffun_new(1,i)>Ffun(1,i)
                        X(i,:)=Xnew(i,:);
                        Ffun(1,i)=Ffun_new(1,i);
                    end
                end
            end
        end
        tiempos(t)=toc; 
        perf15porc(t)=Best_FF;
        conv(t)=Best_FF;
        conv_Accuracy(t)=BestAccuracy;
        conv_GMean(t)=BestGMean;
        t=t+1;
    end
end

function o=Levy(d)
    beta=1.5;
    sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
    u=randn(1,d)*sigma;v=randn(1,d);step=u./abs(v).^(1/beta);
    o=step;
end


