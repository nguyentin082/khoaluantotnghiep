clear; clc;

Na = 64;
Nc = 160;
Nsample = 2000;

% Define SNR range and B values
SNR_dB_range = -30:5:20;  % Phạm vi SNR theo dB
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];  % Các giá trị của B

% Load the ground truth channel matrix
HDL_test = load('HDL_test.mat').HDL_test; % Kích thước 64x160x2000

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value % Kích thước 64x160x2000
H_reconstructed{1} = load('HDL_ori_reconst-BTot512-CR16.mat').HDL_ori_reconst;
H_reconstructed{2} = load('HDL_ori_reconst-BTot768-CR16.mat').HDL_ori_reconst;
H_reconstructed{3} = load('HDL_ori_reconst-BTot1024-CR16.mat').HDL_ori_reconst;
H_reconstructed{4} = load('HDL_ori_reconst-BTot1280-CR16.mat').HDL_ori_reconst;
H_reconstructed{5} = load('HDL_ori_reconst-BTot1536-CR16.mat').HDL_ori_reconst;
H_reconstructed{6} = load('HDL_ori_reconst-BTot1792-CR16.mat').HDL_ori_reconst;
H_reconstructed{7} = load('HDL_ori_reconst-BTot2048-CR16.mat').HDL_ori_reconst;

% Calculate BER for BPSK Precoding random bit
BER_BPSK = BPSK_Precoding(HDL_test, H_reconstructed, Nsample, Na, Nc, SNR_dB_range, B_values);

% Plot BER vs. SNR
BER_BPSK_plot = plot(SNR_dB_range, BER_BPSK, '-o');
BER_BPSK_plot.XGrid = 'on';
BER_BPSK_plot.YGrid = 'on';
BER_BPSK_plot.XLabel.String = 'SNR (dB)';
BER_BPSK_plot.YLabel.String = 'BER';

% Function to calculate BER for BPSK Precoding with random bit
function BER_BPSK = BPSK_Precoding(HDL_test, H_reconstructed, Nsample, Na, Nc, SNR_dB_range, B_values);
    numBits = 100;
    bits = randi([0 1], 1, numBits);

    % BPSK Precoding
    bits = 2 * bits - 1;

    % Add AWGN
    SNR = 10^(SNR_dB_range/10);
    sigma = 1 ./ SNR;
    noise = sigma .* randn(1, numBits);
    noisy_bits = bits + noise;
    
    % BPSK Precoding
    noisy_bits = 2 * noisy_bits - 1;
    BER_BPSK = zeros(1, length(B_values));
    for i = 1:length(B_values)
        B = B_values(i);
        % Calculate the number of errors
        numErrors = 0;
        for j = 1:Nsample
            % Calculate the error
           