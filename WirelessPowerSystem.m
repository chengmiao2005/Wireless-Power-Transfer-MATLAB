classdef WirelessPowerSystem < handle
properties
   
    Us = 100;           % 电源电压 (V)
    f = 100e3;          % 频率 (Hz)
    w                   % 角频率
    
    % 电路参数
    R1 = 0.1;           % 原边电阻 (Ω)
    L1 = 100e-6;        % 原边电感 (H)
    R2 = 0.1;           % 副边电阻 (Ω)
    L2 = 100e-6;        % 副边电感 (H)
    M = 50e-6;          % 互感 (H)
    RL = 10;            % 负载电阻 (Ω)
    
    % 补偿电容
    C1                  % 原边补偿电容 (F)
    C2                  % 副边补偿电容 (F)
    
    % 仿真参数
    t_end = 0.01;       % 仿真时间 (s)
    t                   % 时间向量
end

methods
    function obj = WirelessPowerSystem()
        obj.w = 2 * pi * obj.f;
        obj.calculateCompensationCapacitors();
    end
    
    function calculateCompensationCapacitors(obj)
        % 计算副边补偿电容 C2 (谐振条件)
        obj.C2 = 1 / (obj.w^2 * obj.L2);
        
        % 计算反射阻抗参数
        R1f = obj.R1 + (obj.M^2 / obj.L2^2) * obj.RL;
        L1f = obj.L1 - obj.M^2 / obj.L2;
        
        % 计算原边补偿电容 C1
        obj.C1 = L1f / (obj.w^2 * L1f^2 + R1f^2);
        
        fprintf('计算得到的补偿电容:\n');
        fprintf('C1 = %.2f nF\n', obj.C1 * 1e9);
        fprintf('C2 = %.2f nF\n', obj.C2 * 1e9);
    end
    
    function [Z1, Z2] = calculateImpedance(obj)
        % 计算阻抗
        Z1 = obj.R1 + 1j * obj.w * obj.L1;
        Z2 = obj.R2 + 1j * obj.w * obj.L2 + obj.RL / (1 + 1j * obj.w * obj.RL * obj.C2);
    end
    
    function [I0, I1, I2, IL] = calculateCurrents(obj)
        % 计算各支路电流
        [Z1, Z2] = obj.calculateImpedance();
        
        denominator = Z1 * Z2 + obj.w^2 * obj.M^2;
        
        I1 = (obj.Us * Z2) / denominator;
        I2 = (-1j * obj.w * obj.M * obj.Us) / denominator;
        I0 = 1j * obj.w * obj.C1 * obj.Us + I1;
        IL = I2 / (1 + 1j * obj.w * obj.C2 * obj.RL);
    end
    
    function [P_in, P_out, efficiency] = calculatePower(obj)
        % 计算功率和效率
        [I0, I1, I2, IL] = obj.calculateCurrents();
        
        P_in = real(obj.Us * conj(I0));
        P_out = abs(IL)^2 * obj.RL;
        efficiency = P_out / P_in * 100;
    end
    
    function plotFrequencyResponse(obj, f_min, f_max, n_points)
        % 绘制频率响应曲线
        if nargin < 4
            n_points = 1000;
        end
        if nargin < 3
            f_max = 150e3;
        end
        if nargin < 2
            f_min = 50e3;
        end
        
        f_range = linspace(f_min, f_max, n_points);
        w_range = 2 * pi * f_range;
        
        efficiency = zeros(1, n_points);
        P_out = zeros(1, n_points);
        
        for i = 1:n_points
            w_temp = w_range(i);
            
            % 临时计算该频率下的阻抗
            Z1 = obj.R1 + 1j * w_temp * obj.L1;
            Z2 = obj.R2 + 1j * w_temp * obj.L2 + obj.RL / (1 + 1j * w_temp * obj.RL * obj.C2);
            
            denominator = Z1 * Z2 + w_temp^2 * obj.M^2;
            I2 = (-1j * w_temp * obj.M * obj.Us) / denominator;
            IL = I2 / (1 + 1j * w_temp * obj.C2 * obj.RL);
            
            I0 = 1j * w_temp * obj.C1 * obj.Us + (obj.Us * Z2) / denominator;
            
            P_in = real(obj.Us * conj(I0));
            P_out(i) = abs(IL)^2 * obj.RL;
            efficiency(i) = P_out(i) / P_in * 100;
        end
        
        figure('Position', [100, 100, 1200, 800]);
        
        % 效率曲线
        subplot(2, 2, 1);
        plot(f_range/1e3, efficiency, 'b-', 'LineWidth', 2);
        hold on;
        [~, ~, efficiency_work] = obj.calculatePower();
        plot(obj.f/1e3, efficiency_work, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
        xlabel('频率 (kHz)');
        ylabel('效率 (%)');
        title('系统效率 vs 频率');
        grid on;
        legend('效率曲线', '工作点');
        
        % 输出功率曲线
        subplot(2, 2, 2);
        plot(f_range/1e3, P_out, 'r-', 'LineWidth', 2);
        hold on;
        [~, P_out_work] = obj.calculatePower();
        plot(obj.f/1e3, P_out_work, 'bo', 'MarkerSize', 8, 'LineWidth', 2);
        xlabel('频率 (kHz)');
        ylabel('输出功率 (W)');
        title('输出功率 vs 频率');
        grid on;
        legend('功率曲线', '工作点');
        
        % 阻抗幅频特性
        subplot(2, 2, 3);
        Z1_array = zeros(1, n_points);
        Z2_array = zeros(1, n_points);
        for i = 1:n_points
            w_temp = w_range(i);
            Z1_array(i) = abs(obj.R1 + 1j * w_temp * obj.L1);
            Z2_array(i) = abs(obj.R2 + 1j * w_temp * obj.L2 + obj.RL / (1 + 1j * w_temp * obj.RL * obj.C2));
        end
        plot(f_range/1e3, Z1_array, 'g-', 'LineWidth', 2);
        hold on;
        plot(f_range/1e3, Z2_array, 'm-', 'LineWidth', 2);
        xlabel('频率 (kHz)');
        ylabel('阻抗幅值 (Ω)');
        title('阻抗幅频特性');
        grid on;
        legend('Z1 - 原边阻抗', 'Z2 - 副边阻抗');
        
        % 电流幅频特性
        subplot(2, 2, 4);
        I1_array = zeros(1, n_points);
        IL_array = zeros(1, n_points);
        for i = 1:n_points
            w_temp = w_range(i);
            Z1 = obj.R1 + 1j * w_temp * obj.L1;
            Z2 = obj.R2 + 1j * w_temp * obj.L2 + obj.RL / (1 + 1j * w_temp * obj.RL * obj.C2);
            denominator = Z1 * Z2 + w_temp^2 * obj.M^2;
            I1_array(i) = abs((obj.Us * Z2) / denominator);
            I2 = (-1j * w_temp * obj.M * obj.Us) / denominator;
            IL_array(i) = abs(I2 / (1 + 1j * w_temp * obj.C2 * obj.RL));
        end
        plot(f_range/1e3, I1_array, 'c-', 'LineWidth', 2);
        hold on;
        plot(f_range/1e3, IL_array, 'k-', 'LineWidth', 2);
        xlabel('频率 (kHz)');
        ylabel('电流幅值 (A)');
        title('电流幅频特性');
        grid on;
        legend('I1 - 原边电流', 'IL - 负载电流');
    end
    
    function plotTimeDomainWaveforms(obj)
        % 绘制时域波形
        dt = 1 / (obj.f * 100); % 高采样率
        obj.t = 0:dt:5/obj.f;   % 显示5个周期
        
        [I0, I1, I2, IL] = obj.calculateCurrents();
        
        % 时域信号
        Us_t = obj.Us * cos(obj.w * obj.t);
        I0_t = abs(I0) * cos(obj.w * obj.t + angle(I0));
        I1_t = abs(I1) * cos(obj.w * obj.t + angle(I1));
        IL_t = abs(IL) * cos(obj.w * obj.t + angle(IL));
        
        figure('Position', [100, 100, 1200, 800]);
        
        % 电压波形
        subplot(2, 2, 1);
        plot(obj.t * 1e6, Us_t, 'r-', 'LineWidth', 2);
        xlabel('时间 (μs)');
        ylabel('电压 (V)');
        title('电源电压波形');
        grid on;
        
        % 电流波形
        subplot(2, 2, 2);
        plot(obj.t * 1e6, I0_t, 'b-', 'LineWidth', 2);
        hold on;
        plot(obj.t * 1e6, I1_t, 'g--', 'LineWidth', 2);
        plot(obj.t * 1e6, IL_t, 'r-.', 'LineWidth', 2);
        xlabel('时间 (μs)');
        ylabel('电流 (A)');
        title('电流波形');
        legend('I0 - 输入电流', 'I1 - 原边线圈电流', 'IL - 负载电流');
        grid on;
        
        % 功率波形
        subplot(2, 2, 3);
        P_in_t = Us_t .* I0_t;
        P_out_t = IL_t.^2 * obj.RL;
        plot(obj.t * 1e6, P_in_t, 'b-', 'LineWidth', 2);
        hold on;
        plot(obj.t * 1e6, P_out_t, 'r-', 'LineWidth', 2);
        xlabel('时间 (μs)');
        ylabel('功率 (W)');
        title('瞬时功率');
        legend('输入功率', '输出功率');
        grid on;
        
        % 相位关系
        subplot(2, 2, 4);
        plot(obj.t * 1e6, Us_t/max(Us_t), 'k-', 'LineWidth', 2);
        hold on;
        plot(obj.t * 1e6, I0_t/max(I0_t), 'b--', 'LineWidth', 2);
        plot(obj.t * 1e6, IL_t/max(IL_t), 'r-.', 'LineWidth', 2);
        xlabel('时间 (μs)');
        ylabel('归一化幅值');
        title('相位关系 (归一化)');
        legend('电源电压', '输入电流', '负载电流');
        grid on;
    end
    
    function displaySystemParameters(obj)
        % 显示系统参数
        [I0, I1, I2, IL] = obj.calculateCurrents();
        [P_in, P_out, efficiency] = obj.calculatePower();
        
        fprintf('\n=== 无线能量传输系统参数 ===\n');
        fprintf('工作频率: %.1f kHz\n', obj.f/1e3);
        fprintf('电源电压: %.1f V\n', obj.Us);
        fprintf('负载电阻: %.1f Ω\n', obj.RL);
        fprintf('\n--- 电路参数 ---\n');
        fprintf('L1 = %.1f μH, L2 = %.1f μH\n', obj.L1*1e6, obj.L2*1e6);
        fprintf('M = %.1f μH, 耦合系数 k = %.3f\n', obj.M*1e6, obj.M/sqrt(obj.L1*obj.L2));
        fprintf('R1 = %.3f Ω, R2 = %.3f Ω\n', obj.R1, obj.R2);
        fprintf('\n--- 补偿电容 ---\n');
        fprintf('C1 = %.2f nF, C2 = %.2f nF\n', obj.C1*1e9, obj.C2*1e9);
        fprintf('\n--- 工作状态 ---\n');
        fprintf('输入电流 I0: %.3f∠%.1f° A\n', abs(I0), angle(I0)*180/pi);
        fprintf('原边电流 I1: %.3f∠%.1f° A\n', abs(I1), angle(I1)*180/pi);
        fprintf('副边电流 I2: %.3f∠%.1f° A\n', abs(I2), angle(I2)*180/pi);
        fprintf('负载电流 IL: %.3f∠%.1f° A\n', abs(IL), angle(IL)*180/pi);
        fprintf('输入功率: %.2f W\n', P_in);
        fprintf('输出功率: %.2f W\n', P_out);
        fprintf('传输效率: %.2f%%\n', efficiency);
    end
end
end
