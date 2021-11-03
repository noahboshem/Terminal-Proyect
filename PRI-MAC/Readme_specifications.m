% %%%%%%ARCHVO DE ESPECIFICACIONES PUNTUALES PARA EL PROGRAMA%%%%
% 
% 
%     %%%%%%%%GRAFICAS ADICIONALES%%%%%%%%%
% % figure(2)
% hold on; grid on;
% drop_P = Paquetes_status(:,2)./(Paquetes_status(:,1)+Paquetes_status(:,2));
% p_2 = plot(drop_P,'linewidth',2);
% title("New-packet drop probability");
% xlabel(" [ i ] ");
% p_2(1).Marker = "*";
% figure(3)
% hold on; grid on;
% loss_P = 1-(pkts_rec')./(Paquetes_status(:,1)+Paquetes_status(:,2));
% p_3 = plot(loss_P,'linewidth',2);
% title("Packet loss probability");
% xlabel(" [ i ] ");
% p_3(1).Marker = "*";
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 

