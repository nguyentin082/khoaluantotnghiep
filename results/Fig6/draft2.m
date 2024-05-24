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

% Parameters
nTest = 2000; % Number of test samples
na = 64; % Number of antennas
nc = 160; % Number of subcarriers
numUsers = 8; % Number of users

% SNR values
snr_values = -30:5:10; % SNR values in dB
avg_sum_rates = zeros(length(B_values), length(snr_values)); % Store avg sum rates for each B
perfect_sum_rate = zeros(1, length(snr_values)); % Store avg sum rates for perfect CSI

% Calculate Average Sum Rate for each B value
fprintf('Calculating average sum rate...\n')
for b_idx = 1:length(B_values)
    fprintf('B = %d\n', B_values(b_idx));
    
    for snr_idx = 1:length(snr_values)
        snr = 10^(snr_values(snr_idx) / 10); % Convert dB to linear
        sum_rate = 0;

        for i = 1:numUsers
            % Select random user channels
            user_idx = randperm(nTest, numUsers);
            H_user = H_reconstructed{b_idx}(:,:,user_idx);
            H_est_user = HDL_test(:,:,user_idx);
            
            % Zero-forcing beamforming
            W = pinv(reshape(H_est_user, na, [])); % Precoding matrix
            noise_power = 1 / snr; % Noise power
            
            % Water-filling power allocation
            [U, S, V] = svd(reshape(H_user, na, []));
            s = diag(S);
            power_alloc = waterfilling(noise_power, s.^2);
            rate = sum(log2(1 + power_alloc .* (s.^2) / noise_power));
            
            sum_rate = sum_rate + rate;
        end
        
        avg_sum_rates(b_idx, snr_idx) = sum_rate / numUsers;
    end
end

% Calculate Average Sum Rate for Perfect CSI
fprintf('Calculating average sum rate for perfect CSI...\n');
for snr_idx = 1:length(snr_values)
    snr = 10^(snr_values(snr_idx) / 10); % Convert dB to linear
    sum_rate = 0;

    for i = 1:numUsers
        % Select random user channels
        user_idx = randperm(nTest, numUsers);
        H_user = HDL_test(:,:,user_idx); % Use the perfect channel matrix directly
        
        % Zero-forcing beamforming
        W = pinv(reshape(H_user, na, [])); % Precoding matrix
        noise_power = 1 / snr; % Noise power
        
        % Water-filling power allocation
        [U, S, V] = svd(reshape(H_user, na, []));
        s = diag(S);
        power_alloc = waterfilling(noise_power, s.^2);
        rate = sum(log2(1 + power_alloc .* (s.^2) / noise_power));
        
        sum_rate = sum_rate + rate;
    end
    
    perfect_sum_rate(snr_idx) = sum_rate / numUsers;
end

% Plotting results in a 2x2 subplot
figure;
colors = lines(length(B_values) + 1);
for b_idx = 1:length(B_values)
    subplot(2, 2, b_idx);
    plot(snr_values, avg_sum_rates(b_idx, :), '-o', 'LineWidth', 1.5, 'Color', colors(b_idx,:));
    hold on;
    plot(snr_values, perfect_sum_rate, '-x', 'LineWidth', 1.5, 'Color', colors(end,:));
    xlabel('SNR (dB)');
    ylabel('Average Sum Rate (bits/channel use)');
    title(['Average Sum Rate vs. SNR for B = ', num2str(B_values(b_idx))]);
    legend(['B = ', num2str(B_values(b_idx))], 'Perfect CSI');
    grid on;
end

% Save results
% save('avg_sum_rates.mat', 'avg_sum_rates', 'perfect_sum_rate', 'B_values', 'snr_values');

% Water-filling power allocation function
function power_alloc = waterfilling(noise_power, channel_gains)
    num_channels = length(channel_gains);
    power_alloc = zeros(num_channels, 1);
    water_level = (noise_power + sum(channel_gains)) / num_channels;
    
    for i = 1:num_channels
        power_alloc(i) = max(0, water_level - noise_power / channel_gains(i));
    end
end
