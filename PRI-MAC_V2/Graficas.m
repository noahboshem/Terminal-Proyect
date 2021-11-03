clc;
close all; clear all;

N=[1,2,3,4,5];
Lambda=[0.01,0.02,0.03,0.04,0.05];
Xi=[14,16,18,20,22];
W=[16,32,64,128,256];
K=[5,10,15,20,25];
%%%

%%
  %%%%%%%   VARIANDO N%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
hold on; grid on;
througput=zeros(1,length(N));
avg_timeratio=zeros(1,length(N));
retardo_promedio=zeros(1,7);
for a=1:length(N)
    [througput(a),avg_timeratio(a),retardo_promedio]=PRIMAC(N(a),0.03,18,64,15);
    plot(retardo_promedio,'linewidth',2);
end

title('retardo promedio');


figure(2)
plot(througput,'linewidth',2);
title('througput');
ylim([0.15 0.35]);
grid on;


figure(3)
plot(avg_timeratio,'linewidth',2);
title('avg timeratio')
ylim([0.02 0.06]);
grid on;

%%
 %%%%%%%   VARIANDO Lambda%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
hold on; grid on;
througput=zeros(1,length(Lambda));
avg_timeratio=zeros(1,length(Lambda));
retardo_promedio=zeros(1,7);
for a=1:length(Lambda)
    [througput(a),avg_timeratio(a),retardo_promedio]=PRIMAC(3,Lambda(a),18,64,15);
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

