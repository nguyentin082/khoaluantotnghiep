clear; clc;

% Define SNR range and B values
SNR_dB_range = -30:5:10;  % Define the range of SNR values in dB
B_values = [512, 1024, 1536, 2048];  % Define the values of B

% Load the ground truth channel matrix
H_true = load('HDL_test.mat').HDL_test; % Replace with the correct file loading

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value
H_reconstructed{1} = load('HDL_ori_reconst-BTot512-CR16.mat').HDL_ori_reconst; % Replace with the correct file loading
H_reconstructed{2} = load('HDL_ori_reconst-BTot1024-CR16.mat').HDL_ori_reconst; % Replace with the correct file loading
H_reconstructed{3} = load('HDL_ori_reconst-BTot1536-CR16.mat').HDL_ori_reconst; % Replace with the correct file loading
H_reconstructed{4} = load('HDL_ori_reconst-BTot2048-CR16.mat').HDL_ori_reconst; % Replace with the correct file loading

% Calculate and plot sum rate vs. SNR for different values of B
sum_rate_vs_snr = plot_sum_rate_vs_snr(SNR_dB_range, B_values, H_true, H_reconstructed);

% Function to calculate and plot sum rate vs. SNR
function sum_rate_vs_snr = plot_sum_rate_vs_snr(SNR_dB_range, B_values, H_true, H_reconstructed)
    % SNR_dB_range: range of SNR values in dB
    % B_values: different values of B
    % H_true: ground truth channel matrix (64x160x2000)
    % H_reconstructed: cell array containing reconstructed channel matrices for each B value

    % Define parameters
    numAntennas = size(H_true, 1);
    numSubcarriers = size(H_true, 2);
    numSamples = size(H_true, 3);
    sum_rate_vs_snr = zeros(length(SNR_dB_range), length(B_values) + 1);
    
    % Iterate over the values of B
    for b_idx = 1:length(B_values)
        H_reconstructed_B = H_reconstructed{b_idx};  % Get the channel matrix corresponding to the current B value
        
        % Iterate over the values of SNR
        for snr_idx = 1:length(SNR_dB_range)
            SNR_dB = SNR_dB_range(snr_idx);
            SNR_linear = 10^(SNR_dB/10);
            sum_rate = 0;
            sum_rate_true = 0;

            % Calculate sum rate for each SNR and B
            for i = 1:numSamples
                H_sample = H_reconstructed_B(:,:,i);
                H_true_sample = H_true(:,:,i);

                % Zero-forcing beamforming
                W = pinv(H_sample);  % Precoding matrix
                W_true = pinv(H_true_sample);  % Precoding matrix for true CSI

                % Power allocation with water-filling
                P_alloc = water_filling(H_sample, SNR_linear);
                P_alloc_true = water_filling(H_true_sample, SNR_linear);

                % Calculate sum rate
                rate = calculate_sum_rate(H_sample, W, P_alloc);
                rate_true = calculate_sum_rate(H_true_sample, W_true, P_alloc_true);

                sum_rate = sum_rate + rate;
                sum_rate_true = sum_rate_true + rate_true;
            end
            sum_rate_vs_snr(snr_idx, b_idx) = sum_rate / numSamples;
            sum_rate_vs_snr(snr_idx, end) = sum_rate_true / numSamples;  % Sum rate with perfect CSI
        end
    end
    
    % Plot the results
    figure;
    plot(SNR_dB_range, sum_rate_vs_snr(:,1:end-1), '-o', 'LineWidth', 2);
    hold on;
    plot(SNR_dB_range, sum_rate_vs_snr(:,end), '--k', 'LineWidth', 2);
    legend([arrayfun(@(B) sprintf('B = %d', B), B_values, 'UniformOutput', false), {'Perfect CSI'}], 'Location', 'SouthWest');
    xlabel('SNR (dB)');
    ylabel('Average Sum Rate (bits/channel use)');
    title('Average Sum Rate vs. SNR for different values of B');
    grid on;
end

% Function to calculate the sum rate
function rate = calculate_sum_rate(H, W, P_alloc)
    % Calculate the sum rate for given channel, precoding matrix, and power allocation
    % Input:
    %   H - channel matrix
    %   W - precoding matrix
    %   P_alloc - power allocation vector
    % Output:
    %   rate - calculated sum rate
    
    rate = 0;
    num_streams = size(W, 2);
    for k = 1:num_streams
        H_k = H * W(:,k);
        SINR_k = P_alloc(k) * abs(H_k).^2 / (1 + sum(P_alloc .* abs(H * W).^2, 2) - P_alloc(k) * abs(H_k).^2);
        rate = rate + log2(1 + SINR_k);
    end
    rate = sum(rate(:));  % Ensure rate is a scalar
end

% Function to perform water-filling power allocation
function P_alloc = water_filling(H, SNR_linear)
    % Input:
    %   H - channel matrix
    %   SNR_linear - SNR in linear scale
    % Output:
    %   P_alloc - allocated power vector

    [U, S, V] = svd(H);
    singular_values = diag(S);
    num_channels = length(singular_values);
    total_power = SNR_linear;
    
    % Initialize water level
    water_level = (total_power + sum(1./(singular_values.^2))) / num_channels;
    
    % Calculate power allocation
    P_alloc = max(water_level - 1./(singular_values.^2), 0);
end
