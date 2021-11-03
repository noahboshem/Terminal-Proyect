function [T,Tc,Lam2] = Calculos_iniciales(DIFS,SIFS,RTS,CTS,ACK,DATA,Ro,I,Xi,N,W,LAMBDA)
T=DIFS+Ro*W+RTS+CTS+DATA+ACK+3*SIFS;
Tc=T*(Xi+2);
Lam2=LAMBDA*N*I;
end

