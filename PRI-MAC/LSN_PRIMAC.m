%%%%%%%ROSALES ALANIS NOE RAUL%%%%%%%%%%%%%
%%%%%%%SIMULACION LSN PROTOCOLO PRI-MAC%%%%%%

%%%%PARAMETROS DEL SISTEMA%%%%%%%%%%
    %%%%%DEFINICION DE TIEMPOS PARA EL SISTEMA%%%
DIFS= 10e-3;% Duracion del DFC interframe space
SIFS=  5e-3;% Duracion del short interframe space
RTS = 11e-3;% DURACION REQUEST TO SEND
CTS = 11e-3;% DURACION CLEAR TO SEND
ACK = 11e-3;% DURACION MS ACK
DATA= 43e-3;% DURACION DE PAQUETE DE DATOS
Ro =   1e-3;% DURACION DE UNA MINIRANURA
    %%%VALORES BASE (SA-MAC)%%%%%%
I =   7;      %GRADOS DE LA RED
K= 15;        %TAMAÑO DEL BUFFER
Xi=18;        %NUMERO DE RANURAS DE REPOSO
N=5;          %NUMERO DE NODOS POR GRADO
W=64;         %CANTIDAD MAXIMA DE MINIRANURAS DE CONTENCION
LAMBDA= 3e-2; %TASA DE GENERACION DE PAQUETES EN PAQUETES/SEGUNDO
[T,Tc,Lam2]=Calculos_iniciales(DIFS,SIFS,RTS,CTS,ACK,DATA,Ro,I,Xi,N,W,LAMBDA); %%DESC ON FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ciclos= 1000; %Numero de ciclos
Nodos=init_nodos(I,N);
T_active=zeros(I,N);
T_sleep=zeros(I,N);
T_arribos= -1/LAMBDA*log(1-rand(I,N));
Paquetes_perdidos= zeros(1,I);
Paquetes_status = zeros(I,2);
Paquetes_sink= cell(I,1);
T_sim = 0;
%%%%%%%%%%%%%%%%%%%%%INICIA SIMULACION DE LSN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cyc = 1:Ciclos
    T_sim = T_sim + T; % Ranura de Rx para los nodos de grado I
    while(any(T_arribos(:)<T_sim))
        [T_arribos, Nodos,Paquetes_status] = Update_nodos(T_arribos,Nodos,Paquetes_status,T_sim,LAMBDA,K);
    end
    for slot = 0:I-1
        i = I-slot;
        w = zeros(1,N);
        Tx_any = true(1,N);
        Rx_full = false(1,N);
        for n = 1:N
            if(isempty(Nodos(i,n).buffer))
                Tx_any(n) = false;
            end
            if((i>1)&&length((Nodos(i-1,n).buffer))==K)
                Rx_full(n) = true;
            end
        end
        w(Tx_any) = randi(W,sum(Tx_any),1);
        if(any(Tx_any))
            n = find(w == min(w(w>0)));
            if(length(n)==1)
                pkt = Nodos(i,n).buffer(1);
                Nodos(i,n).buffer = Nodos(i,n).buffer(2:end);
                if(i>1)
                    if(Rx_full(n))
                    % El receptor no despierta ya que tiene buffer lleno
                    Paquetes_perdidos(pkt.grado) = Paquetes_perdidos(pkt.grado)+1;
                    else
                    % Paquete llega al nodo correspondiente de grado i-1
                    Nodos(i-1,n).buffer = [Nodos(i-1,n).buffer,pkt];
                    end
                else % Paquete llega al sink;
                    grado = pkt.grado;
                    retardo = T_sim+DIFS+Ro*w(n)+RTS+CTS+DATA+ACK+3*SIFS-pkt.Ta;
                    Paquetes_sink{grado} = [Paquetes_sink{grado},retardo];
                end
            else % Colision
                for nn = 1:length(n) 
                    ii = Nodos(i,n(nn)).buffer(1).grado;
                    Paquetes_perdidos(ii) = Paquetes_perdidos(ii) +1;
                    Nodos(i,n(nn)).buffer = Nodos(i,n(nn)).buffer(2:end);
                end
            end
        else % No hay paquetes
        end
        T_sim = T_sim +T;
        while(any(T_arribos(:)<T_sim))
            [T_arribos, Nodos,Pkt_stats] = Update_nodos(T_arribos,Nodos,Paquetes_status,T_sim,LAMBDA,K);
        end
    end
    T_sim = T_sim +(Xi-I+1)*T;
    while(any(T_arribos(:)<T_sim))
        [T_arribos, Nodos,Pkt_stats] = Update_nodos(T_arribos,Nodos,Paquetes_status,T_sim,LAMBDA,K);
    end
end
%%%%%%%%%%%%%%%%%%%%%TERMINA SIMULACION DE LSN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%CALCULO DE RETARDO PROMEDIO Y NUMERO DE PAQUETES RECIBIDOS CON EXITO
avg_retardo = zeros(1,I);
pkts_rec = zeros(1,I);
for i = 1:I
retardos = Paquetes_sink{i};
pkts_rec(i) = length(retardos);
avg_retardo(i) = mean(retardos);
end
%%CALCULO DE RENDIMIENTO (THROUGHPUT)
Throughput=(sum(pkts_rec))/T_sim; % Throughput
fprintf('Throughput = %f\n',Throughput);
%%%%INICIA AREA DE GRAFICAS%%%%%%%%%%%%%
    %%%%%GRAFICA DE RETARDO PROMEDIO%%%%%%%%%
figure(1)
hold on; grid on;
ret=plot(avg_retardo,'linewidth',2,'color','b');
ret(1).Marker = "*";
%stem(avg_retardo,'color','b','linewidth',1);
title("Retardo promedio")
ylim([0 1200]); 
    




