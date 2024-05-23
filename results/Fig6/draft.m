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
snr_dB = -30:5:10; % Range of SNR values in dB
nTest = size(HDL_test, 3); % Number of test samples
na = size(HDL_test, 1); % Number of antennas
nc = size(HDL_test, 2); % Number of subcarriers
K = 8; % Number of users

% Initialize sum rate storage
sum_rate = zeros(length(snr_dB), length(B_values));

for snr_idx = 1:length(snr_dB)
    snr = 10^(snr_dB(snr_idx)/10);
    for B_idx = 1:length(B_values)
        B = B_values(B_idx);
        
        % Initialize sum rate for this SNR and B
        rate = zeros(nTest, 1);
        
        for i = 1:nTest
            % Get the original and reconstructed channels
            H_test = HDL_test(:,:,i);
            H_reconst = H_reconstructed{B_idx}(:,:,i);
            
            % Perform zero-forcing beamforming
            H_eff = H_reconst / (H_reconst' * H_reconst); % Effective channel
            W = H_eff * inv(H_eff' * H_eff); % Beamforming matrix
            
            % Water-filling power allocation
            power_alloc = waterfill(snr, diag(H_test' * W * W' * H_test));
            rate(i) = sum(log2(1 + power_alloc .* diag(H_test' * W * W' * H_test)));
        end
        
        % Average sum rate for this SNR and B
        sum_rate(snr_idx, B_idx) = mean(rate);
    end
end

% Plotting
figure;
hold on;
colors = lines(length(B_values));
for B_idx = 1:length(B_values)
    plot(snr_dB, sum_rate(:, B_idx), 'LineWidth', 1.5, 'Color', colors(B_idx, :));
end
xlabel('SNR (dB)');
ylabel('Average Sum Rate (bits/channel use)');
legend(arrayfun(@(B) ['B = ' num2str(B)], B_values, 'UniformOutput', false));
title('Average Sum Rate vs. SNR for different values of B');
grid on;
hold off;

function power_alloc = waterfill(snr, channel_gains)
    % Simple water-filling algorithm for power allocation
    num_users = length(channel_gains);
    power_alloc = zeros(num_users, 1);
    water_level = (snr + sum(1 ./ channel_gains)) / num_users;
    for k = 1:num_users
        power_alloc(k) = max(0, water_level - 1 / channel_gains(k));
    end
end