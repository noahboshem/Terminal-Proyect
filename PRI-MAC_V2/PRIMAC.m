function [out1,out2,out3] = PRIMAC(N,Lambda,Xi,W,K)
%%%%%%%%%NOE RAUL ROSALES ALANIS%%%%%%%%%%%
%%%%%%%%SIMULACION%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%PRIMAC%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------DEFINIMOS VARIABLES GLOBALES--------------------
I         =7; %NUMERO DE GRADOS
%K         =k;%TAMAÑO DEL BUFFER
%Xi        =xi;%NUMERO DE RANURAS DE REPOSO
%N         =nodos; %NUMERO DE NODOS POR GRADO
%W         =window_size;%CANTIDAD MAXIMA DE RANURAS
%Lambda    =lambda;%TASA DE GENERACION DE PAQUETES
Ro        =1e-3;%DURACION DE UNA MINIRANURA
CTS       =11e-3;%DURACION CTS (clear to send)
RTS       =11e-3;%DURACION RTS(request to send)
ACK       =11e-3;%DURACION ACK
DATA      =43e-3;%DURACION PAQUETE DE DATOS
DIFS      =10e-3;%DFC INTERFRAME SPACE
SIFS      =5e-3;%SHORT INTERFRAME SPACE
Time_ratio_rx=zeros(I,N);%%ACUMULADOR PARA "AVERAGE ACTIVE TIME RATIO EN Rx"
Time_ratio_tx=zeros(I,N);%%ACUMULADOR PARA "AVERAGE ACTIVE TIME RATIO EN Tx"
%%%------------------CALCULAMOS DURACION DE CADA RANURA-------
T= DIFS+(Ro*W)+RTS+CTS+DATA+ACK+(3*SIFS);
%%%-----------------definimos variables locales---------------
T_sim=0;                             %TIEMPO DE SIMUACION
Ciclos=70000;                          %NUMERO DE CICLOS
T_arribos= -1/Lambda*log(1-rand(I,N));%%TIEMPO ENTRE ARRIBOS CON DISTRIBUCION DE POISSON
pkt_perdido=zeros(1,I);              %%ACUMULADOR PAQUETES PERDIDOS
pkt_status=zeros(I,2);               %ACMULADOR DE STATUS DE PAQUETES
pkt_sink=cell(I,1);                     %ACUMULADOR PAQUETES LLEGADOS AL SINK
%%---------------------INICIALIZAMOS NODOS-----------------------------
nodos = struct('buffer',{});
for i=1:I
for n = 1:N
nodos(i,n).buffer = [];
end
end
%%-------------COMIENZA CICLO PRINCIPAL------------------------
for cic1=1:Ciclos   %%CORRE TANTOS CICLOS COMO DESEEMOS
    T_sim=T_sim+T; %%AGREGAMOS PRIMER RANURA AL TIEMPO DE SIM(Rx)
    Time_ratio_rx(I,:)=Time_ratio_rx(I,:)+(DIFS+(W*Ro)+RTS);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(any(T_arribos(:)<T_sim))%VERIFICAMOS SI TENEMOS ALGUN PAQUETE DE INICIO
        [T_arribos, nodos,pkt_status] = Actualiza_nodo(T_arribos,nodos,pkt_status,T_sim,Lambda,K);%SI HAY PAQUETE ACTUALIZAMOS NODOS
    end 
    for grad=0:I-1  %%CORRE (#GRADOS) CICLOS
        i=I-grad;   %%OBTENEMOS EL INDICE DEL GRADO QUE VA A TRANSMITIR
        ranura=zeros(1,N);%%ACUMULADOR DE RANURAS(RANURA QUE HA DE ESCOJER CADA NODO)
        tx_flag=true(1,N);%% BANDERAS PARA TRANSMISION
        rx_flag=true(1,N);%%BANDERAS PARA RECEPCION
    for nod=1:N     %%CORRE (#NODOS/GRADO) CICLOS
        if(isempty(nodos(i,nod).buffer)) %%VERIFICAMOS SI EL BUFFER DEL NODO TIENE ALGO PARA TRANSMITIR
            tx_flag(nod)=false; %%EL NODO NO TIENE NADA PARA TRANSMITIR           
        end
        if((i>1)&&length((nodos(i-1,nod).buffer))==K)%%VERIFICAMOS SI EL NODO DEL GRADO I-1 TIENE EL BUFFER LLENO
            rx_flag(nod)=false; %%EL RECEPTOR TIENE EL BUFFER LLENO
        end    
    end
    
    if(i>1)
        Time_ratio_rx(i-1,:)=Time_ratio_rx(i-1,:)+(DIFS+(W*Ro)+RTS);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end 
    
    ranura(tx_flag)=randi(W,sum(tx_flag),1); %%LOS NODOS CON PAQUETES POR TRANSMITIR ELIGEN RANURA
    
    if(any(tx_flag))
    nod = find(ranura == min(ranura(ranura>0)));%%BUSCAMOS LA PRIMERA RANURA (ORDEN ACENDENTE)
    Time_ratio_tx(i,tx_flag)=Time_ratio_tx(i,tx_flag)+(DIFS+(Ro*min(ranura(ranura>0)))+RTS);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(length(nod)==1)%%COMPROBAMOS QUE SOLO HAYA UN NODO GANADOR PARA LA RANURA ELEGIDA
        pkt=nodos(i,nod).buffer(1);%%EXTRAEMOS EL PRIMER PAQUETE DEL NODO
        nodos(i,nod).buffer=nodos(i,nod).buffer(2:end);%%ACTUALIZAMOS EL BUFFER
        if(i>1)%%VERIFICAMOS QUE NO NOS ENCONTRAMOS EN EL NODO SINK
            if(rx_flag(nod)==false)%%EL BUFFER ESTA LLENO en EL NODO RECEPTOR 
                
                Time_ratio_tx(i,nod)=Time_ratio_tx(i,nod)+(SIFS+CTS);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                pkt_perdido(pkt.Grado)=pkt_perdido(pkt.Grado)+1;%%ACUMULAMOS UN PAQUETE PERDIDO EN EL GRADO CORRESPONDIENTE
            else                        %%SI EL BUFFER TIENE ESPACIo
                
                Time_ratio_tx(i,nod)=Time_ratio_tx(i,nod)+((3*SIFS)+CTS+DATA+ACK);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                nodos(i-1,nod).buffer=[nodos(i-1,nod).buffer,pkt];%%AGREGAMOS EL PAQUETE AL BUFFER DEL NODO RECEPTOR
                Time_ratio_rx(i-1,nod)=Time_ratio_rx(i-1,nod)-(DIFS+(W*Ro)+RTS)+((3*SIFS)+CTS+DATA+ACK)+(DIFS+(Ro*min(ranura(ranura>0)))+RTS);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            end
        else %%SI ESTAMOS EN EL GRADO 1 EL PAQUETE SE HA ENTREGADO AL SINK
            
            Time_ratio_tx(i,nod)=Time_ratio_tx(i,nod)+((3*SIFS)+CTS+DATA+ACK);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            grado_origen=pkt.Grado;
            retprim=pkt.T_arribo;
            retardo= T_sim+DIFS+(Ro*min(ranura(ranura>0)))+RTS+CTS+DATA+ACK+(3*SIFS);
            retardo_pkt=retardo-retprim;
            pkt_sink{grado_origen}= [pkt_sink{grado_origen},retardo_pkt];
        end
    else %%SI DOS NODOS ELIGIERON LA MISMA RANURA SE GENERA UNA COLISION
        for nn = 1:length(nod)
            ii = nodos(i,nod(nn)).buffer(1).Grado;
            pkt_perdido(ii) = pkt_perdido(ii) +1;
            Time_ratio_tx(i,nod(nn))=Time_ratio_tx(i,nod(nn))+SIFS+CTS;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            nodos(i,nod(nn)).buffer = nodos(i,nod(nn)).buffer(2:end);
        end
    end
    else %%SI NO HAY NINGUNA BANDERA DE TX NO HAY PAQUETES POR TRANSMITIR
    end
    T_sim = T_sim +T;
    while(any(T_arribos(:)<T_sim))
        [T_arribos,nodos,pkt_status] = Actualiza_nodo(T_arribos,nodos,pkt_status,T_sim,Lambda,K);
    end
    end
    T_sim = T_sim +(Xi-I+1)*T;
    while(any(T_arribos(:)<T_sim))
        [T_arribos, nodos,pkt_status] = Actualiza_nodo(T_arribos,nodos,pkt_status,T_sim,Lambda,K);
    end
end

%%-------------TERMINA CICLO PRINCIPAL------------------------
%%-------------COMIENZA AREA DE GRAFICACION-------------------
    %%PARA EL RETARDO PROMEDIO

retardo_promedio = zeros(1,I);
pkts_recibidos = zeros(1,I);
for i = 1:I
retardos = pkt_sink{i};
pkts_recibidos(i) = length(retardos);
retardo_promedio(i) = mean(retardos);
end
througput=(sum(pkts_recibidos))/T_sim;
%retardo_promedio
avg_timeratio=mean(mean(Time_ratio_tx,2)+mean(Time_ratio_rx,2))/T_sim;
out1=througput;
out2=avg_timeratio;
out3=retardo_promedio;
end

