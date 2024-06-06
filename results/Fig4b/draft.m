clear; clc;

% Define SNR range and B values
SNR_dB_range = -30:5:20;  % Phạm vi SNR theo dB
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];  % Các giá trị của B

% Load the ground truth channel matrix 64x160x2000
HDL_test = load('HDL_test.mat').HDL_test; % Load file và lưu giá trị vào biến

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value 64x160x2000
H_reconstructed{1} = load('HDL_ori_reconst-BTot512-CR16.mat').HDL_ori_reconst;
H_reconstructed{2} = load('HDL_ori_reconst-BTot768-CR16.mat').HDL_ori_reconst;
H_reconstructed{3} = load('HDL_ori_reconst-BTot1024-CR16.mat').HDL_ori_reconst;
H_reconstructed{4} = load('HDL_ori_reconst-BTot1280-CR16.mat').HDL_ori_reconst;
H_reconstructed{5} = load('HDL_ori_reconst-BTot1536-CR16.mat').HDL_ori_reconst;
H_reconstructed{6} = load('HDL_ori_reconst-BTot1792-CR16.mat').HDL_ori_reconst;
H_reconstructed{7} = load('HDL_ori_reconst-BTot2048-CR16.mat').HDL_ori_reconst;

% Calculate and plot BER vs. SNR for different values of B
ber_vs_snr = plot_ber_vs_snr(SNR_dB_range, B_values, HDL_test, H_reconstructed);

function ber_vs_snr = plot_ber_vs_snr(SNR_dB_range, B_values, H_true, H_reconstructed)
    numSamples = size(H_true, 3);  % Số lượng mẫu
    ber_vs_snr = zeros(length(SNR_dB_range), length(B_values) + 1);
    
    % Tạo dữ liệu BPSK
    bits = randi([0 1], 64, 160, numSamples);
    symbols = 2*bits - 1;  % Convert to BPSK symbols

    % Tính BER với CSI hoàn hảo
    for snr_idx = 1:length(SNR_dB_range)
        SNR_dB = SNR_dB_range(snr_idx);
        SNR_linear = 10^(SNR_dB/10);
        noise_var = 1 / SNR_linear;
        noise = sqrt(noise_var/2) * (randn(64, 160, numSamples) + 1i*randn(64, 160, numSamples));
        
        received = symbols .* H_true + noise;
        detected_symbols = received ./ H_true;  % Giải điều chế với CSI hoàn hảo
        detected_bits = real(detected_symbols) > 0;
        
        ber_true = mean(detected_bits(:) ~= bits(:));
        ber_vs_snr(snr_idx, end) = ber_true;  % Lưu BER

        % Display BER for perfect CSI
        fprintf('BER for Perfect CSI, SNR = %d dB: %f\n', SNR_dB, ber_true);
    end

    % Tính BER cho mỗi giá trị B và SNR
    for b_idx = 1:length(B_values)
        H_reconstructed_B = H_reconstructed{b_idx};  % Ma trận kênh tái tạo
        
        for snr_idx = 1:length(SNR_dB_range)
            SNR_dB = SNR_dB_range(snr_idx);
            SNR_linear = 10^(SNR_dB/10);
            noise_var = 1 / SNR_linear;
            noise = sqrt(noise_var/2) * (randn(64, 160, numSamples) + 1i*randn(64, 160, numSamples));
            
            % Tính toán tín hiệu nhận được và tín hiệu giải điều chế
            received = symbols .* H_true + noise;
            detected_symbols = received ./ H_reconstructed_B;  % Giải điều chế
            detected_bits = real(detected_symbols) > 0;
            
            % Tính BER
            ber = mean(detected_bits(:) ~= bits(:));
            ber_vs_snr(snr_idx, b_idx) = ber;

            % Display BER
            fprintf('BER for B = %d, SNR = %d dB: %f\n', B_values(b_idx), SNR_dB, ber);
        end
    end

    % Vẽ biểu đồ
    figure;
    semilogy(SNR_dB_range, ber_vs_snr(:,1:end-1), '-o', 'LineWidth', 2);
    hold on;
    semilogy(SNR_dB_range, ber_vs_snr(:,end), '--k', 'LineWidth', 2);
    legend([arrayfun(@(B) sprintf('B = %d', B), B_values, 'UniformOutput', false), {'Perfect CSI'}], 'Location', 'SouthWest');
    xlabel('SNR (dB)');
    ylabel('BER');
    title('BER vs. SNR for different values of B');
    grid on;
end
