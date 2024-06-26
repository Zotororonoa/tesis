%_______________________________________________________________________________________%
%  Aquila Optimizer (AO) source codes (version 1.0)                                     %
%                                                                                       %
%  Developed in MATLAB R2015a (7.13)                                                    %
%  Author and programmer: Laith Abualigah                                               %
%  Abualigah, L, Yousri, D, Abd Elaziz, M, Ewees, A, Al-qaness, M, Gandomi, A.          %
%         e-Mail: Aligah.2020@gmail.com                                                 %
%       Homepage:                                                                       %
%         1- https://scholar.google.com/citations?user=39g8fyoAAAAJ&hl=en               %
%         2- https://www.researchgate.net/profile/Laith_Abualigah                       %
%                                                                                       %
%   Main paper:                                                                         %
%_____________Aquila Optimizer: A novel meta-heuristic optimization algorithm___________%
%_______________________________________________________________________________________%
% Abualigah, L, Yousri, D, Abd Elaziz, M, Ewees, A, Al-qaness, M, Gandomi, A. (2021). 
% Aquila Optimizer: A novel meta-heuristic optimization algorithm. 
% Computers & Industrial Engineering.
%_______________________________________________________________________________________%

%Si cada una de las variables tiene distintos límites, se adapta.

%Me falta hacer algunas pruebas con el initialization multidimensional.
function [X, forb_matrix]=initialization(N,Dim,UB,LB,forb_matrix)

B_no= size(UB,2); % number of boundaries

if B_no==1
    X=zeros(N,1);
    cont=0;
    while(cont<N)        
        posAux=round(rand(1,Dim).*(UB-LB)+LB);
        res=comprueba_prohibido(posAux,forb_matrix, Dim);
        if(res==true)
           cont=cont+1;
           X(cont)=posAux;
           forb_matrix(posAux)=1;
        end
    end
elseif B_no>1
    X=zeros(N,Dim);
    posAux=zeros(1,Dim);
    cont=0;
    while(cont<N)
        for i=1:Dim
            Ub_i=UB(i);
            Lb_i=LB(i);
            posAux(i)=round(rand(1,1).*(Ub_i-Lb_i)+Lb_i);
        end
        res=comprueba_prohibido(posAux,forb_matrix, Dim);
        if(res==true)
            cont=cont+1;
            X(cont,:)=posAux(:);
            forb_matrix(posAux(1),posAux(2))=1;
        end
    end
end

% % If each variable has a different lb and ub
% elseif B_no>1
%     X=zeros(N,Dim);
%     cont=0;
%     while(cont<N)
%         for i=1:Dim
%             Ub_i=UB(i);
%             Lb_i=LB(i);
%             posAux=rand(N,1).*(Ub_i-Lb_i)+Lb_i;
%             res=comprueba_prohibido(posAux,forb_matrix, Dim);
%             if(res==true)
%                 cont=cont+1;
%                 X(cont,:)=posAux(:);
%                 forb_matrix(posAux)=1;
%             end
%         end
%     end
% end