function [T_arribos, nodos, pkt_status] = Actualiza_nodo(T_arribos,nodos,pkt_status,T_sim,Lambda,K)
 pks=find(T_arribos<T_sim);%%BUSCAMOS LOS PAQUETES QUE SON MENORES QUE EL TIEMPO DE SIMULACION
 sz_pks=length(pks);       %%OBTENEMOS EL NUMERO DE PAQUETES < T_sim
 sz_nodos=size(nodos);     %%OBTENEMOS DIMENCIONES DE LA MATRIZ DE NODOS
 for a=1:sz_pks            %%HACEMOS UN BARRIDO A TODOS LOS PAQUETES < T_sim
    [i,n]= ind2sub(sz_nodos,pks(a));%%OBTENEMOS LOS SUBINDICES DEL NODO A TRANSMITIR
    if(length(nodos(i,n).buffer)<K) %%COMPROBAMOS SI EL BUFFER DEL NODO TIENE ESPACIO
        pkt=struct('Grado',i,'T_arribo',T_arribos(pks(a)));%%SE GENERA UN PAQUETE
        nodos(i,n).buffer=[nodos(i,n).buffer,pkt];%%AGREGAMOS EL PAQUETE GENERADO AL NODO EN QUE SE GENERÓ
        pkt_status(i,1)=pkt_status(i,1)+1;%%CONTABILIZAMOS UN PAQUETE GENERADO CON EXITO
    else                    %%EN CASO DE QUE EL BUFFER DEL NODO ESTE LLENO 
        pkt_status(i,2)=pkt_status(i,2)+1; %%COONTABILIZAMOS UN PAQUETE PERDIDO
    end
    T_arribos(pks(a))=T_arribos(pks(a))-1/Lambda*log(1-rand); %%ACTUALIZAMOS EL TIEMPO DE ARRIBO
 end

end

