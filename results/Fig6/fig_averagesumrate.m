clc; clear;

% Load data
HDL_test = load('HDL_test.mat').HDL_test;

% Define B values
B_values = [512, 1024, 1536, 2048];

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value
H_reconstructed{1} = load('HDL_ori_reconst-BTot512-CR16.mat').HDL_ori_reconst;
H_reconstructed{2} = load('HDL_ori_reconst-BTot1024-CR16.mat').HDL_ori_reconst;
H_reconstructed{3} = load('HDL_ori_reconst-BTot1536-CR16.mat').HDL_ori_reconst;
H_reconstructed{4} = load('HDL_ori_reconst-BTot2048-CR16.mat').HDL_ori_reconst;

P_total = 1; % Total transmit power
num_tests = size(HDL_test, 3);
snr_range = -30:5:10; % SNR range in dB

% Initialize matrix to hold average sum rates for each B and SNR
average_sum_rates = zeros(length(snr_range), length(B_values));

for b = 1:length(B_values)
    sum_rates = zeros(num_tests, length(snr_range));
    H_reconst = H_reconstructed{b};

    for s = 1:length(snr_range)
        snr = 10^(snr_range(s) / 10); % Convert SNR from dB to linear scale
        P_total = snr; % Adjust the total transmit power according to SNR
        
        for i = 1:num_tests
            H_test_i = HDL_test(:, :, i);
            H_reconst_i = H_reconst(:, :, i);
            sum_rates(i, s) = calculate_sum_rate(H_test_i', P_total); % Use H_test_i for sum rate calculation
        end
    end

    average_sum_rates(:, b) = mean(sum_rates, 1);
end

% Plot the average sum rate vs. SNR for different values of B
figure;
colors = {'-o', '-s', '-d', '-^'};
for b = 1:length(B_values)
    subplot(2, 2, b);
    plot(snr_range, average_sum_rates(:, b), colors{b}, 'LineWidth', 2);
    xlabel('SNR (dB)');
    ylabel('Average Sum Rate (bits/channel use)');
    title(['Average Sum Rate vs. SNR for B = ', num2str(B_values(b))]);
    grid on;
end

% Helper functions
function W = calculate_ZF_precoding(H)
    % H is the channel matrix (Na x Nc)
    % W is the zero-forcing precoding matrix (Nc x Na)
    W = (H' / (H * H'))'; % Zero-Forcing Beamforming
end

function p = water_filling(H, P_total)
    % H is the channel matrix (Na x Nc)
    % P_total is the total transmit power
    % p is the power allocation vector

    [U, S, V] = svd(H);
    singular_values = diag(S).^2; % Get the squared singular values

    % Water-filling algorithm
    num_subcarriers = length(singular_values);
    mu = (P_total + sum(1 ./ singular_values)) / num_subcarriers;

    p = max(0, mu - 1 ./ singular_values);
    p = p / sum(p) * P_total; % Normalize to ensure the sum of power equals P_total
end

function rate = calculate_sum_rate(H, P_total)
    % H is the channel matrix (Na x Nc)
    % P_total is the total transmit power

    W = calculate_ZF_precoding(H);
    p = water_filling(H, P_total);

    rate = 0;
    for i = 1:size(H, 2) % Iterate over each subcarrier
        H_i = H(:, i); % Channel vector for subcarrier i
        rate = rate + log2(1 + p(i) * (abs(H_i' * W(:, i)).^2));
    end
end
