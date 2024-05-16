% Example MATLAB script for generating Figure 6

% Load dataset
load('dataset.mat');

% Define parameters
B_values = [512, 1024, 1536, 2048];
num_samples_PCA = 2000;
num_samples_AE = 40000;
num_samples_CsiNetPro = 40000;
SNR_dB = -30:5:10;
K = 8; % Number of users

% Initialize result storage
sum_rate_PCA = zeros(length(SNR_dB), length(B_values));
sum_rate_AE = zeros(length(SNR_dB), length(B_values));
sum_rate_CsiNetPro = zeros(length(SNR_dB), length(B_values));

% Run simulations for each B
for i = 1:length(B_values)
    B = B_values(i);
    
    % PCA
    sum_rate_PCA(:, i) = run_PCA_simulation(dataset, B, num_samples_PCA, K, SNR_dB);
    
    % AE
    sum_rate_AE(:, i) = run_AE_simulation(dataset, B, num_samples_AE, K, SNR_dB);
    
    % CsiNetPro
    sum_rate_CsiNetPro(:, i) = run_CsiNetPro_simulation(dataset, B, num_samples_CsiNetPro, K, SNR_dB);
end

% Plot results
figure;
hold on;
plot(SNR_dB, sum_rate_PCA, '-o', 'DisplayName', 'PCA');
plot(SNR_dB, sum_rate_AE, '-x', 'DisplayName', 'AE');
plot(SNR_dB, sum_rate_CsiNetPro, '-s', 'DisplayName', 'CsiNetPro');
xlabel('SNR [dB]');
ylabel('Average Sum Rate [bits/channel use]');
legend;
title('Average Sum Rate with Zero-Forcing Beamforming');
hold off;

