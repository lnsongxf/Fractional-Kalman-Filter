%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   分数阶卡尔曼滤波器仿真复现
%   论文：Fractional Kalman filter algorithm for the states, parameters and
%        order of fractional system estimation
%   备注：分数阶扩展卡尔曼滤波器算例复现
%  
%   实际状态测试
%           
%   备注：此为论文中分数阶卡尔曼滤波器的复现
%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear

%仿真步长
N = 100;
LineWidth = 1.5;
h_con = sqrt(3);

%状态测量初始化
X_real = zeros(3,N);            %真实状态
X_esti = zeros(3,N);            %状态最优估计值
P_esti = cell(1,N);             %估计误差方差阵
Z_meas = zeros(1,N);            %实际观测值

%系统矩阵设置
% A = [0,1; -0.1,-0.2];           %系统矩阵
% B = [0; 1];                     %
% C = [0.1,0.3];                  %
I = eye(3,3);                     %生成单位阵
%I(3,3) = 0;

%噪声
q = [0 0 0]';                      %系统噪声均值
r = 1;                             %测量噪声均值
Q = [0.3,0,0; 0,0.3,0; 0,0,0.001];%系统噪声方差矩阵
R = 0.3;                           %测量噪声方差矩阵
W_noise = Q*randn(3,N) + q;        %系统噪声
V_noise = R*randn(1,N) + r;        %测量噪声

%初始值设置
P_pred_0 = [100,0,0; 0,100,0;0,0,100];%初始预测方差阵
P_esti{1,1} = P_pred_0;               %初始估计方差阵
x_0  = [0; 0; 0.2];                   %初始状态
X_real(:,1) = x_0;                    %真实状态初始值
X_esti(:,1) = [0;0;0];                %状态估计初始值
Z_meas(:,1) = V_noise(:,1);           %测量数据初始值

%计算alpha阶次对应的GL定义系数 binomial coefficient 
bino_fir = zeros(1,N);          %微分阶次为0.7时GL定义下的系数
alpha = 0.7;
bino_fir(1,1) = 1;
for i = 2:1:N
    bino_fir(1,i) = (1-(alpha+1)/(i-1))*bino_fir(1,i-1);  
end

bino_sec = zeros(1,N);          %微分阶次为1.2时GL定义下的系数
alpha = 1.2;
bino_sec(1,1) = 1;
for i = 2:1:N
    bino_sec(1,i) = (1-(alpha+1)/(i-1))*bino_sec(1,i-1);  
end

bino_thi = zeros(1,N);          %微分阶次为1时GL定义下的系数
alpha = 1;
bino_thi(1,1) = 1;
for i = 2:1:N
    bino_thi(1,i) = (1-(alpha+1)/(i-1))*bino_thi(1,i-1);  
end

%计算GL微分定义下系数矩阵
gamma = cell(1,N);
temp_matrx = zeros(3,3);
for i = 1:1:N 
    temp_matrx(1,1) = bino_fir(1,i);
    temp_matrx(2,2) = bino_sec(1,i);
    temp_matrx(3,3) = bino_thi(1,i);
    gamma{1,i} = temp_matrx;
end

%系统输入设置:前一半输入为1，后一半输入为
U_input = ones(1,N);            
for i = N/2+1:1:N
    U_input(:,i) = -2;
end

%GL定义下短记忆原理的长度
L = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% diff_X_real    表示k时刻状态的微分
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_X_real = [0;0;0];

for k=2:1:N
    %计算实际状态
    diff_X_real = [X_real(2,k-1); ...
                  -0.1*X_real(1,k-1)-X_real(2,k-1)*X_real(3,k-1)+ ...
                  U_input(1,k-1); 0] + W_noise(:,k-1);
    rema = [0;0;0];
    for i = 2:1:k
        rema = rema + gamma{1,i}*X_real(:,k+1-i);
    end
    X_real(:,k) = diff_X_real - rema;
    %实际观测值
    Z_meas(:,k) = 0.1*X_real(1,k) + 0.3*X_real(2,k) + V_noise(1,k);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------自适应分数阶卡尔曼滤波器性能测试-----------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%初始值设置（初始矩阵不能为零）
r_esti_A = zeros(1,N);      %测量噪声均值估计值
R_esti_A = zeros(1,N);      %测量噪声方差矩阵估计值
                            
r_esti_A(1,1) = 0.5;        
R_esti_A(1,1) = 0.3;        
    
for k=2:1:N
%卡尔曼滤波
        %状态预测:X_pre
        diff_X_esti = [X_esti(2,k-1); ...
                       -0.1*X_esti(1,k-1)-X_esti(2,k-1)*X_esti(3,k-1)+ ...
                       U_input(1,k-1); 0];
            %计算余项
            rema = [0;0;0];
            if k>L
                for i = 2:1:L+1
                   rema = rema + gamma{1,i}*X_esti(:,k+1-i);
                end
            else
                for i = 2:1:k
                    rema = rema + gamma{1,i}*X_esti(:,k+1-i);
                end
            end
        X_pre = diff_X_esti - rema + q;     %一步状态预测
        %预测误差协方差矩阵:P_pred

            %对误差矩阵进行cholsky分解
            S_chol = chol(P_esti{1,k-1})';

            %计算余项
            rema_P = [0,0,0;0,0,0;0,0,0];
            if k>L+1
                for i = 2:1:L+2
                    rema_P = rema_P + gamma{1,i}*P_esti{1,k+1-i}*gamma{1,i}';
                end
            else
                for i = 2:1:k
                    rema_P = rema_P + gamma{1,i}*P_esti{1,k+1-i}*gamma{1,i}';
                end
            end

        temp_f_plus_hs1 = [X_esti(2,k-1)+ h_con*S_chol(2,1); ...
                           -0.1*(X_esti(1,k-1)+h_con*S_chol(1,1))- ...
                           (X_esti(2,k-1)+h_con*S_chol(2,1))*( X_esti(3,k-1) ...
                           +h_con*S_chol(3,1))+U_input(1,k-1); 0];
        temp_f_subtraction_hs1 = [X_esti(2,k-1)-h_con*S_chol(2,1); ...
                         -0.1*(X_esti(1,k-1)-h_con*S_chol(1,1))- ...
                         (X_esti(2,k-1)-h_con*S_chol(2,1))* ...
                         (X_esti(3,k-1)-h_con*S_chol(3,1))+U_input(1,k-1); 0];   

        temp_f_plus_hs2 = [X_esti(2,k-1)+ h_con*S_chol(2,2); ...
                         -0.1*(X_esti(1,k-1)+h_con*S_chol(1,2))- ...
                         (X_esti(2,k-1)+h_con*S_chol(2,2))* ...
                         (X_esti(3,k-1)+h_con*S_chol(3,2))+U_input(1,k-1); 0];
        temp_f_subtraction_hs2 = [X_esti(2,k-1)-h_con*S_chol(2,2); ...
                         -0.1*(X_esti(1,k-1)-h_con*S_chol(1,2))- ...
                         (X_esti(2,k-1)-h_con*S_chol(2,2)) * ...
                         (X_esti(3,k-1)-h_con*S_chol(3,2))+U_input(1,k-1); 0]; 

        temp_f_plus_hs3 = [X_esti(2,k-1)+h_con*S_chol(2,3); ...
                         -0.1*(X_esti(1,k-1)+h_con*S_chol(1,3))- ...
                         (X_esti(2,k-1)+h_con*S_chol(2,3))* ...
                         (X_esti(3,k-1)+h_con*S_chol(3,3))+U_input(1,k-1); 0];
        temp_f_subtraction_hs3 = [X_esti(2,k-1)-h_con*S_chol(2,3); ...
                         -0.1*(X_esti(1,k-1)-h_con*S_chol(1,3))- ...
                         (X_esti(2,k-1)-h_con*S_chol(2,3)) * ...
                         (X_esti(3,k-1)-h_con*S_chol(3,3))+U_input(1,k-1); 0]; 

        temp_initial = ( 0.5*(temp_f_plus_hs1-temp_f_subtraction_hs1)*S_chol(:,1)'+ ...
                         0.5*(temp_f_plus_hs2-temp_f_subtraction_hs2)*S_chol(:,2)'+ ...
                         0.5*(temp_f_plus_hs3-temp_f_subtraction_hs3)*S_chol(:,3)' ...
                         )*gamma{1,2}'; 

        %F = [0,1,0; -0.1,-X_esti(3,k-1),-X_esti(2,k-1); 0,0,0];
        %P_pred = (F-gamma{1,2})*P_esti{1,k-1}*(F-gamma{1,2})'+ Q + rema_P;
        P_pred = 1/(4*h_con^2)*( ...
                  (temp_f_plus_hs1 - temp_f_subtraction_hs1)*(temp_f_plus_hs1 - temp_f_subtraction_hs1)'  ...
                 +(temp_f_plus_hs2 - temp_f_subtraction_hs2)*(temp_f_plus_hs2 - temp_f_subtraction_hs2)'  ...
                 +(temp_f_plus_hs3 - temp_f_subtraction_hs3)*(temp_f_plus_hs3 - temp_f_subtraction_hs3)'  ...
                ) + ...
                - 1/h_con * temp_initial - 1/h_con * temp_initial' + ...
                + Q + rema_P;

        %对状态预测误差协方差矩阵进行cholsky分解
        S_chol_pred = chol(P_pred)';

        %测量值估计  Z_esti ---- Z_k|k-1
        Z_esti = 0.1*X_pre(1,1) + 0.3*X_pre(2,1) + r_esti_A(1,k-1);

        %测量预测误差协方差矩阵:P_zpred ---- P_z_k|k-1
        P_zpred = 1/(4*h_con^2) * ( ... 
                  ( 0.1* (X_pre(1,1)+h_con*S_chol_pred(1,1)) + 0.3*(X_pre(2,1)+h_con*S_chol_pred(2,1)) ...
                   - ...
                   0.1* (X_pre(1,1)-h_con*S_chol_pred(1,1)) - 0.3*(X_pre(2,1)-h_con*S_chol_pred(2,1)) ...
                   )^2 + ...
                  ...
                  ( 0.1* (X_pre(1,1)+h_con*S_chol_pred(1,2)) + 0.3*(X_pre(2,1)+h_con*S_chol_pred(2,2)) ...
                   - ...
                   0.1* (X_pre(1,1)-h_con*S_chol_pred(1,2)) - 0.3*(X_pre(2,1)-h_con*S_chol_pred(2,2)) ...
                   )^2 + ...
                   ...
                  ( 0.1* (X_pre(1,1)+h_con*S_chol_pred(1,3)) + 0.3*(X_pre(2,1)+h_con*S_chol_pred(2,3)) ...
                   - ...
                   0.1* (X_pre(1,1)-h_con*S_chol_pred(1,3)) - 0.3*(X_pre(2,1)-h_con*S_chol_pred(2,3)) ...
                   )^2 ...
                  ) ...
                  + R;%_esti_A(1,k-1)

        %预测误差互协方差矩阵:P_xzpred
        Y_pre =  X_pre; % inv(S_chol_pred) * 
        P_xzpred = 1/(2*h_con) * ( ... 
                  ( 0.1* (X_pre(1,1)+h_con*S_chol_pred(1,1)) + 0.3*(X_pre(2,1)+h_con*S_chol_pred(2,1)) ...
                   - ...
                   0.1* (X_pre(1,1)-h_con*S_chol_pred(1,1)) - 0.3*(X_pre(2,1)-h_con*S_chol_pred(2,1)) ...
                   ) * S_chol_pred(:,1) + ...
                  ...
                  ( 0.1* (X_pre(1,1)+h_con*S_chol_pred(1,2)) + 0.3*(X_pre(2,1)+h_con*S_chol_pred(2,2)) ...
                   - ...
                   0.1* (X_pre(1,1)-h_con*S_chol_pred(1,2)) - 0.3*(X_pre(2,1)-h_con*S_chol_pred(2,2)) ...
                   ) * S_chol_pred(:,2) + ...
                   ...
                  ( 0.1* (X_pre(1,1)+h_con*S_chol_pred(1,3)) + 0.3*(X_pre(2,1)+h_con*S_chol_pred(2,3)) ...
                   - ...
                   0.1* (X_pre(1,1)-h_con*S_chol_pred(1,3)) - 0.3*(X_pre(2,1)-h_con*S_chol_pred(2,3)) ...
                   ) * S_chol_pred(:,3)  ...
                  );

        %计算卡尔曼增益:Kk(2*1)
        Kk = P_xzpred/P_zpred;

        %测量噪声均值估计
        r_esti_A(k) = ( (k-1)*r_esti_A(k-1) + Z_meas(1,k) - (0.1*X_pre(1,1) + 0.3*X_pre(2,1)) )/k;

        %状态更新
        X_esti(:,k) = X_pre + Kk*( Z_meas(1,k) - Z_esti );

        %估计方差矩阵更新
        P_esti{1,k} = P_pred - Kk*P_zpred*Kk';

        %测量噪声方差估计
        %R_esti_A(1,k) = ( (k-1)*R_esti_A(1,k-1) - P_zpred + R_esti_A(1,k-1) + ...
        %             ( Z_meas(:,k) - Z_esti )^2 )/k;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%画图输出
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%输入与测量输出图
k = 1:1:N;
figure;
plot(k,U_input,'b',k,Z_meas,':r','linewidth',LineWidth);
legend('输入','测量输出','Location','best');

%状态估计图
figure;
plot(k,X_real(1,:),'b',k,X_esti(1,:),':r','linewidth',LineWidth);
legend('实际状态1','估计状态1','Location','best');

%状态估计图
figure;
plot(k,X_real(2,:),'b',k,X_esti(2,:),':r','linewidth',LineWidth);
legend('实际状态2','估计状态2','Location','best');

%状态估计图
figure;
plot(k,X_real(3,:),'b',k,X_esti(3,:),':r','linewidth',LineWidth);
legend('实际状态3','估计状态3','Location','best');

%误差图
%误差计算
% err_state = zeros(2,N);
figure;
err_state = X_real - X_esti;
plot(k,r_esti_A(1,k),':r','linewidth',LineWidth);
legend('估计测量噪声均值','Location','best');
line([0,N],[r,r]);






