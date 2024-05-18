clc; clear;

numAntennas = 64;
numBits = 160; % Number of bits for simulation
numSamples = 2000;
SNR_dB = -30:5:0; % SNR range in dB
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048]; % Feedback lengths
BER = zeros(length(SNR_dB), length(B_values)); % Initialize BER matrix
BER_perfect = zeros(1, length(SNR_dB)); % Initialize BER for perfect channel knowledge

% Load the ground truth channel matrix
HDL_test = load('HDL_test.mat').HDL_test;

% Load the channel matrices for each feedback length
H_reconstructed = cell(1, length(B_values));
for idx = 1:length(B_values)
    filename = sprintf('HDL_ori_reconst-BTot%d-CR16.mat', B_values(idx));
    H_reconstructed{idx} = load(filename).HDL_ori_reconst;
end

for j = 1:length(B_values)
    channel = H_reconstructed{j};
    % Call the BER calculation function
    BER(:, j) = calculateBER(numBits, SNR_dB, channel, HDL_test, numSamples);
end

% Calculate BER with perfect channel knowledge
BER_perfect = calculateBERPerfectChannel(numBits, SNR_dB, numSamples, numAntennas);

% Plotting the results
figure;
hold on;
for j = 1:length(B_values)
    semilogy(SNR_dB, BER(:, j), 'LineWidth', 2);
end
semilogy(SNR_dB, BER_perfect, 'k--', 'LineWidth', 2); % Add perfect channel knowledge plot
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs. SNR for Different Feedback Lengths');
legend([arrayfun(@(x) sprintf('B = %d', x), B_values, 'UniformOutput', false), {'Perfect Channel Knowledge'}]);
hold off;

function BER = calculateBER(numBits, SNR_dB, channel, channel_true, numSamples)
    [numAntennas, ~, ~] = size(channel);
    BER = zeros(1, length(SNR_dB));
    
    for i = 1:length(SNR_dB)
        SNR = 10^(SNR_dB(i)/10); % Convert SNR from dB to linear scale
        total_errors = 0;
        total_bits = 0;
        
        for sample_idx = 1:numSamples
            % Generate random bits
            bits = randi([0 1], numAntennas, numBits);
            % Modulate bits (BPSK)
            symbols = 2*bits - 1;
            
            % Pass symbols through the reconstructed channel with AWGN
            channel_sample = channel(:, :, sample_idx);
            channel_true_sample = channel_true(:, :, sample_idx);
            noise = (1/sqrt(2)) * (randn(size(symbols)) + 1j*randn(size(symbols)));
            received_symbols = channel_sample .* symbols + noise / sqrt(SNR);
            received_true_symbols = channel_true_sample .* symbols + noise / sqrt(SNR);
            
            % Demodulate received symbols
            received_bits = real(received_symbols) > 0;
            received_true_bits = real(received_true_symbols) > 0;
            % Calculate errors
            total_errors = total_errors + sum(bits ~= received_bits, 'all');
            total_bits = total_bits + numel(bits);
        end
        
        % Calculate BER for the current SNR
        BER(i) = total_errors / total_bits;
        disp(['SNR (dB): ', num2str(SNR_dB(i)), ', BER: ', num2str(BER(i))]);
    end
end

function BER = calculateBERPerfectChannel(numBits, SNR_dB, numSamples, numAntennas)
    BER = zeros(1, length(SNR_dB));
    
    for i = 1:length(SNR_dB)
        SNR = 10^(SNR_dB(i)/10); % Convert SNR from dB to linear scale
        total_errors = 0;
        total_bits = 0;
        
        for sample_idx = 1:numSamples
            % Generate random bits
            bits = randi([0 1], numAntennas, numBits);
            % Modulate bits (BPSK)
            symbols = 2*bits - 1;
            
            % Pass symbols through AWGN channel only
            noise = (1/sqrt(2)) * (randn(size(symbols)) + 1j*randn(size(symbols)));
            received_symbols = symbols + noise / sqrt(SNR); % No channel effect, only AWGN
            
            % Demodulate received symbols
            received_bits = real(received_symbols) > 0;
            % Calculate errors
            total_errors = total_errors + sum(bits ~= received_bits, 'all');
            total_bits = total_bits + numel(bits);
        end
        
        % Calculate BER for the current SNR
        BER(i) = total_errors / total_bits;
        disp(['Perfect Channel - SNR (dB): ', num2str(SNR_dB(i)), ', BER: ', num2str(BER(i))]);
    end
end
