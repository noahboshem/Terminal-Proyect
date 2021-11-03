clc; clear; 
%close all; 
%% ---------- Parametros del sistema a simular ---------
DIFS = 10e-3;           % DCF Inter Frame Space
SIFS = 5e-3;            % Short Inter Frame Space
durRTS = 11e-3;         % Duracion paquete Request To Send
durCTS = 11e-3;         % Duracion paquete Clear To Send
durACK = 11e-3;         % Duracion paquete Acknowledge 
durDATA = 43e-3;        % Duracion paquete de Datos
Ro = 1e-3;              % Duracion de una mini Ranura 
I = 7;                  % Grados en la red 
N = 5;                  % Nodos por grado 
lambda = 0.03;          % Tasa de generacion de paquetes (pkt/s)
Xi = 18;                % Ranuras de reposo 
W = 64;                 % Cantidad max de mini ranuras de contencion
K = 15;                 % Tamaño del bufer del nodo (QTY paquetes)

Ptx = 52.2;             % Potencia de transmision en mW
Prx = 59.9;             % Potencia de recepcion en mW 
Psp = 0;                % Potencia de reposo en mW
%% ------
T = DIFS+Ro*W+durRTS+durCTS+durDATA+durACK+3*SIFS;  % Duracion de cada ranura
Tc = T*(Xi+2);                                      % Duracion de un ciclo LNS
lambda2 = lambda*N*I;
%% ------
%tic
%profile on
N_ciclos = 50000;
nodos = Inicia_nodos(I,N);
T_tx = zeros(I,N);
T_rx = zeros(I,N); 
T_sp = ones(I,N)*N_ciclos*Tc; 
T_arribos = -1/lambda*log(1-rand(I,N));

pkts_perdidos = zeros(1,I);
Pkt_stats = zeros(I,2);
Pkts_sink = cell(I,1); 
t_sim = 0;
t_Xi = (Xi-I+1)*T;
t_1 = DIFS + W*Ro+durRTS;  
t_2 = 3*SIFS + durCTS + durDATA + durACK;

p_r = zeros(1,I); 
p_s = zeros(1,I); 
p_c = zeros(1,I);
p_c2 = zeros(1,I); 
%%
for cyc = 1:N_ciclos
    % Ranura de Rx para los nodos de grado I
    Rx_full = false(1,N);
    for n = 1:N
        if(length((nodos(I,n).buffer))== K)
            Rx_full(n) =  true; 
        end
    end
    
    t_sim = t_sim + T;
%     T_rx(I,~Rx_full)= T_rx(I,~Rx_full) + t_1;
%     T_sp(I,~Rx_full)= T_sp(I,~Rx_full) - t_1;
    T_rx(I,:)= T_rx(I,:) + t_1;
    T_sp(I,:)= T_sp(I,:) - t_1;

    
    while(any(T_arribos(:)<t_sim))
        [T_arribos, nodos, Pkt_stats] = update_nodos(T_arribos,nodos,Pkt_stats,t_sim,lambda,K);
    end
    
    for slot = 0:I-1
        i = I-slot;
        w = zeros(1,N);

        Tx_any = true(1,N);
        Rx_full = false(1,N);
        for n = 1:N
            if(isempty(nodos(i,n).buffer))
                Tx_any(n) = false;
            end
            if((i>1)&&length((nodos(i-1,n).buffer))==K)
                Rx_full(n) =  true; 
            end
        end
        w(Tx_any) = randi(W,sum(Tx_any),1);
        win = min(w(w>0));
        t_3 = DIFS + win*Ro+durRTS;
        if(i>1)
%             T_sp(i-1,~Rx_full) = T_sp(i-1,~Rx_full) - t_1; 
%             T_rx(i-1,~Rx_full) = T_rx(i-1,~Rx_full) + t_1;
            T_sp(i-1,:) = T_sp(i-1,:) - t_1; 
            T_rx(i-1,:) = T_rx(i-1,:) + t_1;
        end
        if(any(Tx_any))
            
            T_sp(i, Tx_any) = T_sp(i, Tx_any) - t_3; 
            T_tx(i, Tx_any) = T_tx(i, Tx_any) + t_3; 
            n = find(w == win);
            
            if(length(n)==1)
                pkt = nodos(i,n).buffer(1); 
                nodos(i,n).buffer = nodos(i,n).buffer(2:end);
                if(i>1)                
                    if(Rx_full(n))
                        T_tx(i,n) = T_tx(i,n)  + SIFS + durCTS; 
                        T_sp(i,n) = T_sp(i,n)  - SIFS - durCTS;
                       
                        
                        
                        % El receptor no despierta ya que tiene buffer lleno
                        pkts_perdidos(pkt.grado) = pkts_perdidos(pkt.grado)+1;
                    else 
                        T_tx(i,n) = T_tx(i,n) + t_2;
                        T_sp(i,n) = T_sp(i,n) - t_2;
                        
                        T_rx(i-1,n) = T_rx(i-1,n) - t_1 + t_2 + t_3;
                        T_sp(i-1,n) = T_sp(i-1,n) + t_1 - t_2 - t_3;
                        % Paquete llega al nodo correspondiente de grado i-1
                        p_s(i) = p_s(i)+1; 
                        p_r(i-1) = p_r(i-1)+1; 
                        nodos(i-1,n).buffer = [nodos(i-1,n).buffer,pkt];                        
                    end
                else % Paquete llega al sink;
                    p_s(i) = p_s(i)+1; 
                    T_tx(i,n) = T_tx(i,n) + t_2; 
                    T_sp(i,n) = T_sp(i,n) - t_2;
                    grado = pkt.grado;
                    retardo = t_sim+DIFS+Ro*w(n)+durRTS+durCTS+durDATA+durACK+3*SIFS-pkt.Ta;
                    Pkts_sink{grado} = [Pkts_sink{grado},retardo]; 
                end
            else % Colision
                
                p_c(i) = p_c(i)+1; 
                for nn = 1:length(n)
                    p_c2(i) = p_c2(i)+1; 
                    T_tx(i,n(nn)) = T_tx(i,n(nn)) + SIFS + durCTS; 
                    T_sp(i,n(nn)) = T_sp(i,n(nn)) - SIFS - durCTS;
                    ii = nodos(i,n(nn)).buffer(1).grado;
                    pkts_perdidos(ii) = pkts_perdidos(ii) + 1; 
                    nodos(i,n(nn)).buffer = nodos(i,n(nn)).buffer(2:end); 
                end
            end
%       else % No hay paquetes 
        end
        t_sim = t_sim +T;
        
        while(any(T_arribos(:)<t_sim))
            [T_arribos, nodos,Pkt_stats] = update_nodos(T_arribos,nodos,Pkt_stats,t_sim,lambda,K);
        end
    end
    
    t_sim = t_sim + t_Xi;
    
    while(any(T_arribos(:)<t_sim))
        [T_arribos, nodos,Pkt_stats] = update_nodos(T_arribos,nodos,Pkt_stats,t_sim,lambda,K);
    end

end 
%profile viewer
%toc
p_r = p_r/(N_ciclos*N);
p_s = p_s/(N_ciclos*N);
p_c = p_c/(N_ciclos*N);
p_c2 = p_c2/(N_ciclos*N);
%% 
avg_retardo = zeros(1,I);
pkts_rec = zeros(1,I);
for i = 1:I
    retardos = Pkts_sink{i};
    pkts_rec(i) = length(retardos);
    avg_retardo(i) = mean(retardos);
end
figure(1)
hold on; grid on; 
p_1 = plot(avg_retardo,'linewidth',2);
p_1(1).Marker = "*";
title("Retardo promedio source-to-sink")
xlabel(" [ i ] "); 
ylabel(" [ s ] "); 

figure(2)
hold on; grid on;
drop_P = Pkt_stats(:,2)./(Pkt_stats(:,1)+Pkt_stats(:,2));
p_2 = plot(drop_P,'linewidth',2);
title("New-packet drop probability");
xlabel(" [ i ] ");
p_2(1).Marker = "*";

figure(3)
hold on; grid on;
loss_P = 1-(pkts_rec')./(Pkt_stats(:,1)+Pkt_stats(:,2));
p_3 = plot(loss_P,'linewidth',2);
title("Packet loss probability");
xlabel(" [ i ] ");
p_3(1).Marker = "*";

figure(4)
hold on; grid on; 
P_nodos = 1e-3*(T_tx*Ptx + T_rx*Prx + T_sp*Psp)/t_sim;
T_active = (T_tx+T_rx)/(N_ciclos*Tc);
p_4 = plot(sum(P_nodos,2),'linewidth',2);
%p_4 = plot(sum(T_active,2),'linewidth',2);
title("Energy consumption");
xlabel(" [ i ] ");
p_4(1).Marker = "*";

Thpt = (sum(pkts_rec))/t_sim

Avg_active = mean(sum(T_active,2)/N)

%% ------ Funciones ----- 
function [nodos] = Inicia_nodos(I,N)
    nodos = struct('buffer',{});
    for i=1:I
        for n = 1:N
            %nodos(i,n).grado = i;
            nodos(i,n).buffer = [];
        end
    end
end

function [T_arribos, nodos, Pkt_stats] = update_nodos(T_arribos,nodos,Pkt_stats,Tsim,lambda,K)
    ind = find(T_arribos<Tsim);
    n_a = length(ind);  
    sz = size(nodos);
    %[ii,nn] = ind2sub(sz,ind);
    for k = 1:n_a
        [i,n]= ind2sub(sz,ind(k));
        %i = ii(k); n = nn(k); 
        if(length(nodos(i,n).buffer)<K)
            pkt = struct('grado',i,'Ta',T_arribos(ind(k)));
            nodos(i,n).buffer = [nodos(i,n).buffer,pkt];
            Pkt_stats(i,1) = Pkt_stats(i,1)+1;
        else
%             pkt = struct('grado',i,'Ta',T_arribos(ind(k)));
%             nodos(i,n).buffer = [nodos(i,n).buffer(2:end),pkt];
            Pkt_stats(i,2) = Pkt_stats(i,2)+1;
        end 
        T_arribos(ind(k))= T_arribos(ind(k)) -1/lambda*log(1-rand);
    end
    %T_arribos(ind)= T_arribos(ind)-1/lambda*log(1-rand(n_a,1));
end