%% ----------------- Parametros del sistema a simular ----------------
clc;
clear all;
DIFS = 10e-3; % DCF Inter Frame Space
SIFS = 5e-3; % Short Inter Frame Space
durRTS = 11e-3; % Duracion paquete Request To Send
durCTS = 11e-3; % Duracion paquete Clear To Send
durACK = 11e-3; % Duracion paquete Acknowledge
durDATA = 43e-3; % Duracion paquete de Datos
Ro = 1e-3; % Duracion de una mini Ranura
I = 7; % Grados en la red
K = 15; % Tamaño del bufer del nodo (QTY paquetes)
Xi = 18; % Ranuras de reposo
N = 5; % Nodos por grado
W = 64; % Cantidad max de mini ranuras de contencion
lambda = 0.03; % Tasa de generacion de paquetes (pkt/s)
%% -----------------------------------------------------------------------------
T = DIFS+(Ro*W)+durRTS+durCTS+durDATA+durACK+(3*SIFS); % Duracion de cada ranura
%% -----------------------------------------------------------------------------
N_ciclos = 10000; %%definimos el numero de ciclos
nodos = Inicia_nodos(I,N); %%iniciamos los nodos
%T_active = zeros(I,N);%% se define variable para el tiempo activo
%T_sleep = zeros(I,N); %% definicion de variable para tiempo inactivo
T_arribos = -1/lambda*log(1-rand(I,N));%%Tiempo entre arribos con distrubusion de poisson
pkts_perdidos = zeros(1,I);%%matriz contabilizadore de paquetes perdidos
Pkt_stats = zeros(I,2); %%Indicador del estado de los paquetes-----
Pkts_sink = cell(I,1);%------------
t_sim = 0;% Acumulador_Tiempo de simulacion
for cyc = 1:N_ciclos  %%ciclo principal##########################################
%     disp('mod1:');
t_sim = t_sim + T; % Ranura de Rx para los nodos de grado I
while(any(T_arribos(:)<t_sim))%%%verificamos si tenemos paquetes desde inicio
[T_arribos, nodos,Pkt_stats] = Actualiza_nodo(T_arribos,nodos,Pkt_stats,t_sim,lambda,K);%%actualizamos los nodos
end
for slot = 0:I-1 %%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
i = I-slot; %%obtenermos el indice del grado que va a transmitir
w = zeros(1,N); %%Ranura que escoje cada nodo
Tx_any = true(1,N);
Rx_full = false(1,N);
for n = 1:N %%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if(isempty(nodos(i,n).buffer))
Tx_any(n) = false;
end
if((i>1)&&length((nodos(i-1,n).buffer))==K)
Rx_full(n) = true;
end
end %%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
w(Tx_any) = randi(W,sum(Tx_any),1);
if(any(Tx_any))
n = find(w == min(w(w>0)));
if(length(n)==1)
pkt = nodos(i,n).buffer(1);
nodos(i,n).buffer = nodos(i,n).buffer(2:end);
if(i>1)
if(Rx_full(n))
% El receptor no despierta ya que tiene buffer lleno
pkts_perdidos(pkt.grado) = pkts_perdidos(pkt.grado)+1;
else
% Paquete llega al nodo correspondiente de grado i-1
nodos(i-1,n).buffer = [nodos(i-1,n).buffer,pkt];
end
else % Paquete llega al sink;
grado = pkt.grado;
retardo = t_sim+DIFS+Ro*w(n)+durRTS+durCTS+durDATA+durACK+3*SIFS-pkt.Ta;
Pkts_sink{grado} = [Pkts_sink{grado},retardo];
end
else % Colision
for nn = 1:length(n)
ii = nodos(i,n(nn)).buffer(1).grado;
pkts_perdidos(ii) = pkts_perdidos(ii) +1;
nodos(i,n(nn)).buffer = nodos(i,n(nn)).buffer(2:end);
end
end
else % No hay paquetes
end
% disp('mod2:');
t_sim = t_sim +T;
while(any(T_arribos(:)<t_sim))
[T_arribos, nodos,Pkt_stats] = Actualiza_nodo(T_arribos,nodos,Pkt_stats,t_sim,lambda,K);
end
end %%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% disp('mod3:');
t_sim = t_sim +(Xi-I+1)*T;
while(any(T_arribos(:)<t_sim))
[T_arribos, nodos,Pkt_stats] = Actualiza_nodo(T_arribos,nodos,Pkt_stats,t_sim,lambda,K);
end
end %%##########################################################################
%% -----------------------------------------------------------------------------

avg_retardo = zeros(1,I);
pkts_rec = zeros(1,I);
for i = 1:I
retardos = Pkts_sink{i};
pkts_rec(i) = length(retardos);
avg_retardo(i) = mean(retardos);
end
T_arribos
avg_retardo

figure(1)
hold on; grid on;
p_1 = plot(avg_retardo,'linewidth',2);
p_1(1).Marker = "*";
title("Retardo promedio source-to-sink")
xlabel(" [ i ] "); ylabel(" [ s ] ");
% figure(2)
% hold on; grid on;
% drop_P = Pkt_stats(:,2)./(Pkt_stats(:,1)+Pkt_stats(:,2));
% p_2 = plot(drop_P,'linewidth',2);
% title("New-packet drop probability");
% xlabel(" [ i ] ");
% p_2(1).Marker = "*";
% figure(3)
% hold on; grid on;
% loss_P = 1-(pkts_rec')./(Pkt_stats(:,1)+Pkt_stats(:,2));
% p_3 = plot(loss_P,'linewidth',2);
% title("Packet loss probability");
% xlabel(" [ i ] ");
% p_3(1).Marker = "*";
(sum(pkts_rec))/t_sim % Throughput
%% -----------------------------------------Funciones -------------------------------------------
function [nodos] = Inicia_nodos(I,N)
nodos = struct('buffer',{});
for i=1:I
for n = 1:N
%nodos(i,n).grado = i;
nodos(i,n).buffer = [];
end
end
end


function [T_arribos, nodos, Pkt_stats] = Update_nodo(T_arribos,nodos,Pkt_stats,Tsim,lambda,K)
ind = find(T_arribos<Tsim);
n_a = length(ind);
sz = size(nodos);
for k = 1:n_a
[i,n]= ind2sub(sz,ind(k));
if(length(nodos(i,n).buffer)<K)
pkt = struct('grado',i,'Ta',T_arribos(ind(k)));
nodos(i,n).buffer = [nodos(i,n).buffer,pkt];
Pkt_stats(i,1) = Pkt_stats(i,1)+1;
else
Pkt_stats(i,2) = Pkt_stats(i,2)+1;
end
T_arribos(ind(k))= T_arribos(ind(k)) -1/lambda*log(1-rand);
end
end
