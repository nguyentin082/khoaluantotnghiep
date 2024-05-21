clc; clear;

% Load data
HDL_test = load('HDL_test.mat').HDL_test;
HDL_ori_reconst = load('HDL_ori_reconst-BTot512-CR16.mat').HDL_ori_reconst;

P_total = 1; % Total transmit power
num_tests = size(HDL_test, 3);
sum_rate = zeros(num_tests, 1);

for i = 1:num_tests
    H_test_i = HDL_test(:, :, i);
    H_reconst_i = HDL_ori_reconst(:, :, i);
    sum_rate(i) = calculate_sum_rate(H_reconst_i', P_total);
end

average_sum_rate = mean(sum_rate);
disp(['Average Sum Rate: ', num2str(average_sum_rate), ' bits/channel use']);

snr_range = -30:5:10; % SNR range in dB
average_sum_rates = zeros(length(snr_range), 1);

for s = 1:length(snr_range)
    snr = 10^(snr_range(s) / 10); % Convert SNR from dB to linear scale
    P_total = snr; % Adjust the total transmit power according to SNR

    sum_rate = zeros(num_tests, 1);
    for i = 1:num_tests
        H_test_i = HDL_test(:, :, i);
        H_reconst_i = HDL_ori_reconst(:, :, i);
        sum_rate(i) = calculate_sum_rate(H_reconst_i', P_total);
    end

    average_sum_rates(s) = mean(sum_rate);
end

% Plot the average sum rate vs. SNR
figure;
plot(snr_range, average_sum_rates, '-o', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Average Sum Rate (bits/channel use)');
title('Average Sum Rate vs. SNR');
grid on;

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
