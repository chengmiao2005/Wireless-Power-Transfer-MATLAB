clear; clc;

f = 100e3;          % 频率 100 kHz
w = 2*pi*f;         % 角频率
Us = 100;           % 电源电压 100V
RL = 10;            % 负载电阻 10Ω

%% 线圈参数
L1 = 100e-6;        % 原边电感 100 μH
L2 = 100e-6;        % 副边电感 100 μH
M = 50e-6;          % 互感 50 μH
R1 = 0.1;           % 原边电阻 0.1 Ω
R2 = 0.1;           % 副边电阻 0.1 Ω

%% 计算补偿电容
% 副边谐振电容
C2 = 1/(w^2 * L2);

% 原边补偿电容计算
R1f = R1 + (M^2 / L2^2) * RL;
L1f = L1 - M^2 / L2;
C1 = L1f / (w^2 * L1f^2 + R1f^2);

%% 显示计算结果
fprintf('=== 无线能量传输系统参数 ===\n\n');
fprintf('基本参数:\n');
fprintf('工作频率:     f  = %.1f kHz\n', f/1e3);
fprintf('电源电压:     Us = %.1f V\n', Us);
fprintf('负载电阻:     RL = %.1f Ω\n\n', RL);

fprintf('线圈参数:\n');
fprintf('原边电感:     L1 = %.1f μH\n', L1*1e6);
fprintf('副边电感:     L2 = %.1f μH\n', L2*1e6);
fprintf('互感:         M  = %.1f μH\n', M*1e6);
fprintf('原边电阻:     R1 = %.3f Ω\n', R1);
fprintf('副边电阻:     R2 = %.3f Ω\n\n', R2);

fprintf('补偿电容:\n');
fprintf('原边电容:     C1 = %.3f nF\n', C1*1e9);
fprintf('副边电容:     C2 = %.3f nF\n\n', C2*1e9);

fprintf('谐振验证:\n');
fprintf('原边谐振频率: %.2f kHz\n', 1/(2*pi*sqrt(L1*C1))/1e3);
fprintf('副边谐振频率: %.2f kHz\n', 1/(2*pi*sqrt(L2*C2))/1e3);
fprintf('系统工作频率: %.1f kHz\n\n', f/1e3);

fprintf('耦合系数:     k = %.3f\n', M/sqrt(L1*L2));

%% 保存参数到工作区（用于Simulink）
assignin('base', 'C1_value', C1);
assignin('base', 'C2_value', C2);
assignin('base', 'L1_value', L1);
assignin('base', 'L2_value', L2);
assignin('base', 'M_value', M);
assignin('base', 'R1_value', R1);
assignin('base', 'R2_value', R2);
assignin('base', 'RL_value', RL);
assignin('base', 'Us_value', Us);
assignin('base', 'f_value', f);

fprintf('参数已保存到MATLAB工作区，可以在Simulink中使用\n');
