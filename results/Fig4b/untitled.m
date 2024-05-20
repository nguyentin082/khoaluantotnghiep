clear; clc;
na = 64;
nc = 160;
nSamples = 2000;

% Define SNR range
SNR_dB = -30:5:10;
SNR = 10.^(SNR_dB / 10);

% Define feedback bit lengths
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];

% Load the ground truth channel matrix
HDL_test = load('HDL_test.mat').HDL_test; % Load file và lưu giá trị vào biến

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value
H_reconstructed{1} = load('HDL_ori_reconst-BTot512-CR16.mat').HDL_ori_reconst;
H_reconstructed{2} = load('HDL_ori_reconst-BTot768-CR16.mat').HDL_ori_reconst;
H_reconstructed{3} = load('HDL_ori_reconst-BTot1024-CR16.mat').HDL_ori_reconst;
H_reconstructed{4} = load('HDL_ori_reconst-BTot1280-CR16.mat').HDL_ori_reconst;
H_reconstructed{5} = load('HDL_ori_reconst-BTot1536-CR16.mat').HDL_ori_reconst;
H_reconstructed{6} = load('HDL_ori_reconst-BTot1792-CR16.mat').HDL_ori_reconst;
H_reconstructed{7} = load('HDL_ori_reconst-BTot2048-CR16.mat').HDL_ori_reconst;

% Placeholder for BER results
BER_results = zeros(length(B_values), length(SNR_dB));

for i = 1:length(B_values)
    B = B_values(i);
    
    for j = 1:length(SNR)
        % Calculate BER for given B and SNR
        BER_results(i, j) = calculateBER(HDL_test, H_reconstructed{i}, SNR(j), na, nc, nSamples);
    end
end

figure;
hold on;
for i = 1:length(B_values)
    semilogy(SNR_dB, BER_results(i, :), 'DisplayName', ['B = ' num2str(B_values(i))]);
end
hold off;
xlabel('SNR (dB)');
ylabel('BER');
legend show;
grid on;
title('BER vs. SNR for different values of B');

function ber = calculateBER(HDL_test, HDL_ori_reconstructed, SNR, num_antennas, num_subcarriers, num_samples)
    % Initialize variables
    num_bits = 1e5; % Number of bits for BPSK
    num_errors = 0;

    % Generate BPSK symbols
    tx_bits = randi([0 1], num_bits, 1);
    tx_symbols = 2 * tx_bits - 1;

    % Loop over samples
    for sc = 1:num_samples
        H_test = HDL_test(:, :, sc);
        H_reconstructed = HDL_ori_reconstructed(:, :, sc);
        
        % Precoding with reconstructed channel
        W = pinv(H_reconstructed); % Zero-forcing precoder

        % Transmit symbols
        tx_signal = W * tx_symbols;

        % Add noise
        noise = (randn(num_antennas, num_bits) + 1i * randn(num_antennas, num_bits)) / sqrt(2);
        rx_signal = H_test * tx_signal + noise / sqrt(SNR);

        % Decode received symbols
        rx_bits = real(rx_signal) > 0;

        % Count errors
        num_errors = num_errors + sum(rx_bits ~= tx_bits);
    end

    % Calculate BER
    ber = num_errors / (num_bits * num_samples);
end
