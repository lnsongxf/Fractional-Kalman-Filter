clc
clear
N = 100;
k = 100;
r = 1;
LineWidth = 1.5;

load SE_FEKF
load SE_FCDKF
load SE_PF

k = 1:1:N;

%参数估计图
figure;
%err_state = X_real - X_esti_A;
plot(k,SE_FCDKF,'b',k,SE_FEKF,'--r',k,SE_PF,'-.g', ...
    'linewidth',LineWidth);
%line([0,N],[r,r],'linewidth',1,'color','b','LineStyle','--');
parameter_r = legend('$\hat{r}$','r','Location','best');
set(parameter_r,'Interpreter','latex')
set(gcf,'Position',[200 200 400 300]); 
axis([0 100 0 5]) %设置坐标轴在指定的区间
axis normal
ylabel('SE','FontSize',7)
xlabel('iteration times','FontSize',8)
%设置坐标轴刻度字体名称，大小
set(gca,'FontName','Helvetica','FontSize',8)
%legend('real state','estimated state','Location','best');
legend('FCDKF','FEKF','FPF','Location','best');




% %平方误差图
% %square error
% figure;
% set(gcf,'Position',[200 200 400 300]); 
% err_state_A1 = ( X_real(1,:) - X_esti_A(1,:) ).^2; %
% err_state_B1 = ( X_real(1,:) - X_esti_B(1,:) ).^2; %
% err_state_A2 = ( X_real(2,:) - X_esti_A(2,:) ).^2; %
% err_state_B2 = ( X_real(2,:) - X_esti_B(2,:) ).^2; %
% err_state_A3 = ( X_real(3,:) - X_esti_A(3,:) ).^2; %
% err_state_B3 = ( X_real(3,:) - X_esti_B(3,:) ).^2; %
% 
% subplot(311)
% plot(k,err_state_A1(1,:),'b',k,err_state_B1(1,:),'--r','linewidth',LineWidth);
% %set(gcf,'Position',[200 200 400 300]); 
% axis([0 100 0 30]) %axis([xmin xmax ymin ymax])设置坐标轴在指定的区间
% axis normal
% ylabel('SE(x_1)','FontSize',7)
% xlabel('iteration times','FontSize',8)
% %设置坐标轴刻度字体名称，大小
% %legend('real state','estimated state','Location','best');
% %legend('FCDKF','FEKF','Location','best');
% 
% subplot(312)
% plot(k,err_state_A2(1,:),'b',k,err_state_B2(1,:),'--r','linewidth',LineWidth);
% %set(gcf,'Position',[200 200 400 300]); 
% axis([0 100 0 5]) 
% %axis([xmin xmax ymin ymax])设置坐标轴在指定的区间
% axis normal
% ylabel('SE(x_2)','FontSize',7)
% xlabel('iteration times','FontSize',8)
% %设置坐标轴刻度字体名称，大小
% set(gca,'FontName','Helvetica','FontSize',8)
% % legend('real state','estimated state','Location','best');
% % legend('FCDKF','FEKF','Location','best');
% 
% subplot(313)
% plot(k,err_state_A3(1,:),'b',k,err_state_B3(1,:),'--r','linewidth',LineWidth);
% %set(gcf,'Position',[200 200 400 300]); 
% axis([0 100 0 0.02]) 
% %axis([xmin xmax ymin ymax])设置坐标轴在指定的区间
% axis normal
% ylabel('SE(x_3)','FontSize',7)
% xlabel('iteration times','FontSize',8)
% %设置坐标轴刻度字体名称，大小
% set(gca,'FontName','Helvetica','FontSize',8)
% % legend('real state','estimated state','Location','best');
%  legend('AFCDKF','FEKF','Location','best');
% 
% 
% 
% %状态估计图
% % k = 1:1:N;
% % figure;
% % plot(k,X_real(3,:),'b',k,X_esti_A(3,:),'--r',k,X_esti_B(3,:),':g','linewidth',LineWidth);
% % legend('实际状态3','FCDKF估计状态3','FEKF估计状态3','Location','best');
% % 
% % figure;
% % plot(k,X_real(2,:),'b',k,X_esti_A(2,:),'--r',k,X_esti_B(2,:),':g','linewidth',LineWidth);
% % legend('实际状态2','FCDKF估计状态2','FEKF估计状态2','Location','best');
% % 
% % hold on
% % plot(k,X_real(1,:),'b',k,X_esti_A(1,:),'--r',k,X_esti_B(1,:),':g','linewidth',LineWidth);
% % legend('实际状态1','FCDKF估计状态1','FEKF估计状态1','Location','best');
% 




