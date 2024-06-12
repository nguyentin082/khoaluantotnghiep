clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];

% Load avg_sum_rates.mat for PCA and Perfect
load('CalculateSumratePCAandPerfect/avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này
avg_sum_rates_PCA_and_Perfect = avg_sum_rates; % Lưu trữ kết quả vào một biến riêng biệt

% Load avg_sum_rates.mat for CsiNet
load('CalculateSumrateCsiNet/avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này
avg_sum_rates_CsiNet = avg_sum_rates; % Lưu trữ kết quả vào một biến riêng biệt

% Combine to 1 matrix
combined_avg_sum_rates = [avg_sum_rates_PCA_and_Perfect; avg_sum_rates_CsiNet];

% Tạo các giá trị SNR
SNR_values = -30:5:10; % Các giá trị SNR từ -30 đến 10 dB

% Tạo hình vẽ 2x2 subplot
figure;
for i = 1:4
    subplot(2, 2, i);
    hold on;
    plot(SNR_values, combined_avg_sum_rates(5, :), 'k-', 'LineWidth', 2); % Perfect Channel
    plot(SNR_values, combined_avg_sum_rates(i, :), 'r', 'LineWidth', 2); % PCA value
    plot(SNR_values, combined_avg_sum_rates(5+i, :), 'b', 'LineWidth', 2); % CsiNet value
    title(['B = ', num2str(B_values(i))]);
    xlabel('SNR (dB)');
    ylabel('Average Sum Rate (bits/channel use)');
    legend('Perfect Channel', 'PCA', 'CsiNet', 'Location', 'Best');
    grid on;
    hold off;
end
