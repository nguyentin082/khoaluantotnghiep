clear; clc;

% Load HDL_test và HDL_ori_reconst từ tập tin .mat đã lưu
load('HDL_test.mat');
load('HDL_ori_reconst.mat');

% Xác định số lượng bit của mỗi mẫu dữ liệu
num_samples = size(HDL_test, 3); % Số lượng mẫu
num_bits_per_sample = numel(HDL_test(:, :, 1)); % Số lượng bit trong mỗi mẫu

% Khởi tạo mảng lưu tín hiệu nhận
received_signals = zeros(size(HDL_ori_reconst));

% Chuẩn bị mảng SNR từ -30dB đến 0dB
snr_range = -30:1:0; % Khoảng SNR từ -30dB đến 0dB

% Tính BER cho mỗi giá trị SNR
bers = zeros(size(snr_range));
for i = 1:length(snr_range)
    % Tính năng lượng của nhiễu tương ứng với mỗi giá trị SNR
    snr_linear = 10^(snr_range(i) / 10); % SNR ở dạng tuyến tính
    noise_power = 1 / snr_linear; % Năng lượng của nhiễu
    
    for j = 1:num_samples
        % Tạo nhiễu Gaussian trắng
        noise = sqrt(noise_power) * (randn(size(HDL_ori_reconst(:, :, j))) + 1i * randn(size(HDL_ori_reconst(:, :, j))));
        
        % Tính tín hiệu nhận y = HDL_ori_reconst * x + noise
        % As you haven't defined 'x', let's assume it's a vector of ones for now
        x = ones(size(HDL_ori_reconst, 2), 1); % Assuming x is a vector of ones
        received_signals(:, :, j) = HDL_ori_reconst(:, :, j) * x + noise;
        
        % Precoding BPSK trên HDL_test theo HDL_ori_reconst
        precoded_HDL_test = sign(real(received_signals)) + 1i * sign(imag(received_signals)); % Changed from HDL_ori_reconst
        
        % Tính BER cho mỗi mẫu dữ liệu
        % Mảng lưu BER cho từng mẫu
        num_errors = nnz(precoded_HDL_test(:, :, j) - HDL_test(:, :, j)); % Count number of errors
        ber_per_sample(j) = num_errors / num_bits_per_sample; % Calculate BER for this sample
    end
    
    % Tính tỷ lệ lỗi bit trung bình cho mỗi giá trị SNR
    bers(i) = mean(ber_per_sample); % Calculate average BER for this SNR
end

% Vẽ đồ thị BER theo SNR
figure;
semilogy(snr_range, bers, 'o-');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs SNR');
