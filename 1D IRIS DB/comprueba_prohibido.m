function salida=comprueba_prohibido(pos,matrizF, Dim)
    if Dim ==1
        if(matrizF(pos)==1)
            salida=false;
        else
            salida=true;
        end
    elseif Dim==2
        if(matrizF(pos(1),pos(2))==1)
            salida=false;
        else
            salida=true;
        end   
    end
end