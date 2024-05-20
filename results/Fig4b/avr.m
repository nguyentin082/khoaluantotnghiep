clc; clear;


% Assume the necessary variables (e.g., H_test, HDL_ori_reconst) are already loaded
% Load the ground truth channel matrix
H_test = load('HDL_test.mat').HDL_test; % Load file và lưu giá trị vào biến
% Load the reconstructed channel matrix
H_reconstructed = load('HDL_ori_reconst.mat').HDL_ori_reconst;

K = 8; % Number of single-antenna users
na = 64;
nc =160;
NC = 160; % Number of OFDM subcarriers
nTest = size(H_test,3);

average_sum_rate = 0;
num_iterations = 100; % Number of Monte Carlo simulations

for iter = 1:num_iterations
    selected_users = randperm(nTest, K);
    H_test_selected = H_test(:,:,selected_users);
    HDL_reconst_selected = H_reconstructed(:,:,selected_users);
    
    % Zero-forcing beamforming
    sum_rate = 0;
    for nC = 1:NC
        H = HDL_reconst_selected(:,nC,:);
        H = reshape(H, [na, K]);
        W = (H' * H + eye(K)) \ H'; % Pseudo-inverse
        power_allocation = waterfilling(W, SNR);
        sum_rate = sum_rate + sum(log2(1 + diag(power_allocation)));
    end
    average_sum_rate = average_sum_rate + sum_rate / NC;
end

average_sum_rate = average_sum_rate / num_iterations;
fprintf('Average Sum Rate: %.2f bits/channel use\n', average_sum_rate);
