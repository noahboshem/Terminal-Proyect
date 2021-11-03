function [T_arribos, nodos, Pkt_stats] = Update_nodos(T_arribos,nodos,Pkt_stats,Tsim,lambda,K)
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

