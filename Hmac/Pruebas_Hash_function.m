%%pruebas hash

%%
clc;
N=6;       %%%%Numero de nodos
winprob=zeros(1,N);
ciclos=90000;
for an=1:ciclos
cicl=an;   %%%Numero de ciclo
nodos=zeros(1,N); %%Nodos
p=N;       %%Prime number
ranura=zeros(1,N);
while(isprime(p)==0) %%para satisfacer   p>=N  & p tiene que ser un numero primo
        p=p+1;
end 
rng(cicl);  %%SEMILLA
an=randi([1,p-1]);  %%asignamos an
bn=randi([1,p-1]);  %%asignamos bn
colision=0;
for r= 1:N
    first=(an*r)+bn;
    ranura(r)=mod(first,p);
end
    if(length(unique(ranura))~= N)
       colision=colision+1; 
    end
win=find(ranura == min(ranura));
winprob(win)=winprob(win)+1;
end
colision
winerprob=winprob/ciclos
plot(winerprob,'linewidth',2);
title('Probabilidad de ganar por nodo');
xlabel('Nodos');
ylabel('Probabilidad');
ylim([0 1]);

