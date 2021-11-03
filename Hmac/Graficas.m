clc;
close all; clear all;

N=[10,15,20];
Lambda=[0.001,0.003,0.005];
Xi=[14,16,18,20,22];
W=[16,32,64,128,256];
K=[5,10,15,20,25];
%%%

%%
  %%%%%%%   VARIANDO N%%%%%%%%%%%%%%%%%%%%%%%%%%%%% retardo promedio
  %%%%%%%   variando  N con lambda=0.001
figure(1)
hold on; grid on;
througput=zeros(1,length(N));
avg_timeratio=zeros(1,length(N));
retardo_promedio=zeros(1,7);
for a=1:length(N)
    [througput(a),avg_timeratio(a),retardo_promedio]=H_MAC(N(a),0.005,18,N(a),15);
    plot(retardo_promedio,'linewidth',2);
end

title('retardo promedio');
ylim([0 3500]);

%%  para la probalbilidad de paquetes perdidos
figure(1)
hold on; grid on;
througput=zeros(1,length(N));
avg_timeratio=zeros(1,length(N));
retardo_promedio=zeros(1,7);
pkt_loss=zeros(1,7);
for a=1:length(N)
    [througput(a),avg_timeratio(a),retardo_promedio,pkt_loss]=H_MAC(N(a),0.005,18,N(a),15);
    plot(pkt_loss,'linewidth',2);
end

title('Packet loss probability');
ylim([0 1]);



%%
retardo_prom=[5.6087,6.5147,7.0521,7.4043,7.7670,8.0869,8.3500;454.9600,646.3018,649.9732,655.3031,652.9834,656.6691,657.4101;719.981976739501,1369.81572738616,1833.52240227167,1865.94434791520,1865.38503211791,1860.38121286070,1867.32832990535];
plot(retardo_prom,'linewidth',2);
ylim([0 3500]);
%%
 %%%%%%%   VARIANDO Lambda y N%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Grafica de througput
througput=zeros(1,length(N));
avg_timeratio=zeros(1,length(N));
retardo_promedio=zeros(1,7);
for b=1:length(Lambda)
for a=1:length(N)
    b
    a
    [througput(a),avg_timeratio(a),retardo_promedio]=H_MAC(N(a),Lambda(b),18,N(a),15);
end
figure(5)
plot(througput,'linewidth',2);
title('througput');
ylim([0 0.70]);
grid on;
hold on;
end

%%
%%%%%%%   VARIANDO Xi%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
hold on; grid on;
througput=zeros(1,length(Xi));
avg_timeratio=zeros(1,length(Xi));
retardo_promedio=zeros(1,7);
for a=1:length(Xi)
    [througput(a),avg_timeratio(a),retardo_promedio]=PRIMAC(3,0.03,Xi(a),64,15);
    plot(retardo_promedio,'linewidth',2);
end
title('retardo promedio');


figure(5)
plot(througput,'linewidth',2);
title('througput');
ylim([0.15 0.35]);
grid on;


figure(6)
plot(avg_timeratio,'linewidth',2);
title('avg timeratio')
ylim([0.02 0.06]);
grid on;


%%
%%%%%%%   VARIANDO W%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
hold on; grid on;
througput=zeros(1,length(W));
avg_timeratio=zeros(1,length(W));
retardo_promedio=zeros(1,7);
for a=1:length(W)
    [througput(a),avg_timeratio(a),retardo_promedio]=PRIMAC(3,0.03,18,W(a),15);
    plot(retardo_promedio,'linewidth',2);
end
title('retardo promedio');


figure(5)
plot(througput,'linewidth',2);
title('througput');
ylim([0.15 0.35]);
grid on;


figure(6)
plot(avg_timeratio,'linewidth',2);
title('avg timeratio')
ylim([0.02 0.06]);
grid on;

%%
%%%%%%%   VARIANDO K%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
hold on; grid on;
througput=zeros(1,length(K));
avg_timeratio=zeros(1,length(K));
retardo_promedio=zeros(1,7);
for a=1:length(K)
    [througput(a),avg_timeratio(a),retardo_promedio]=PRIMAC(3,0.03,18,64,K(a));
    plot(retardo_promedio,'linewidth',2);
end
title('retardo promedio');


figure(5)
plot(througput,'linewidth',2);
title('througput');
ylim([0.15 0.35]);
grid on;


figure(6)
plot(avg_timeratio,'linewidth',2);
title('avg timeratio')
ylim([0.02 0.06]);
grid on;

