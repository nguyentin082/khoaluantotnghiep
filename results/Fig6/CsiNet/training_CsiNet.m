% % Input:
% % H_train [64 x 160 x 40,000]
% % H_test [64 x 160 x 2,000]
% 
% clear; clc;
% rng(47);
% 
% % Parameters
% na = 64;                % # of BS antennas
% nc = 160;               % # of OFDM subcarriers
% nTrain = 40000;          % # of training samples
% nTest = 2000;           % # of test samples
% CR = 16;                % Compression ratio
% BTot = 256*5;           % Total feedback bits = 1280
% snrTrain = 10;          % Noise level in training samples. Value in linear units: -1=infdB or 1=0dB, 10=10dB, 1000=30dB
% snrTest = 10;           % Noise level in test samples. Value in linear units: -1=infdB or 1=0dB, 10=10dB, 1000=30dB
% 
% %% Import and preprocess data
% fprintf('Importing and preprocessing data...\n')
% 
% H_train = load('H_train_expanded.mat').H_train_expanded; % load scaled H_train_expanded.mat
% H_test = load('H_test.mat').H_test;
% 
% % UL Training
% HUL_train_n = H_train;
% Lambda = squeeze(1 ./ mean(abs(HUL_train_n).^2,[1 2])); % Tính Lambda
% if snrTrain ~= -1 % Thêm nhiễu Gaussian vào dữ liệu huấn luyện
%     nPower = 1 ./ (Lambda * snrTrain); % Tính công suất nhiễu
%     HN = bsxfun(@times, randn(na, nc, nTrain) + 1i * randn(na, nc, nTrain), reshape(sqrt(nPower / 2), 1, 1, [])); % Tạo nhiễu Gaussian
%     HUL_train_n = H_train + HN; % Thêm nhiễu vào ma trận kênh
%     Lambda = squeeze(1 ./ mean(abs(HUL_train_n).^2,[1 2])); % Tính lại Lambda
% end
% HUL_train_n = bsxfun(@times, HUL_train_n, reshape(sqrt(Lambda), 1, 1, [])); % Chuẩn hóa ma trận kênh
% HUL_train_compl_tmp = reshape(HUL_train_n, na * nc, nTrain).'; % Định dạng lại ma trận kênh
% HUL_train_compl_tmp_mean = mean(HUL_train_compl_tmp); % Tính giá trị trung bình
% HUL_train_compl = bsxfun(@minus, HUL_train_compl_tmp, HUL_train_compl_tmp_mean); % Trừ đi giá trị trung bình
% 
% % DL Testing
% HDL_test_n = H_test;
% Lambda = squeeze(1 ./ mean(abs(HDL_test_n).^2,[1 2])); % Tính Lambda
% HDL_test = bsxfun(@times, HDL_test_n, reshape(sqrt(Lambda), 1, 1, [])); % Chuẩn hóa ma trận kênh
% if snrTest ~= -1 % Thêm nhiễu Gaussian vào dữ liệu kiểm tra
%     for q = 1:nTest
%         nPower = mean(abs(H_test(:, :, q)).^2, 'all') / snrTest; % Tính công suất nhiễu
%         HDL_test_n(:, :, q) = H_test(:, :, q) + sqrt(nPower / 2) * (randn(na, nc) + 1i * randn(na, nc)); % Thêm nhiễu Gaussian
%     end
%     Lambda = squeeze(1 ./ mean(abs(HDL_test_n).^2,[1 2])); % Tính lại Lambda
% end
% HDL_test_n = bsxfun(@times, HDL_test_n, reshape(sqrt(Lambda), 1, 1, [])); % Chuẩn hóa ma trận kênh
% HDL_test_compl_tmp = reshape(HDL_test_n, na * nc, nTest).'; % Định dạng lại ma trận kênh
% HDL_test_compl = bsxfun(@minus, HDL_test_compl_tmp, HUL_train_compl_tmp_mean); % Trừ đi giá trị trung bình
% 
% % Lưu các ma trận vào các tệp .mat riêng biệt
% save('HUL_train_compl_tmp.mat', 'HUL_train_compl_tmp', '-v7.3');
% save('HUL_train_compl_tmp_mean.mat', 'HUL_train_compl_tmp_mean', '-v7.3');
% save('HUL_train_compl.mat', 'HUL_train_compl', '-v7.3');
% save('HDL_test_compl_tmp.mat', 'HDL_test_compl_tmp', '-v7.3');
% save('HDL_test_compl.mat', 'HDL_test_compl', '-v7.3');
% 
% disp('Data saved successfully.');

%% Clear workspace and command window
clear; clc;

%% Load các ma trận từ các tệp .mat vào các biến
HUL_train_compl_tmp = load('HUL_train_compl_tmp.mat').HUL_train_compl_tmp; %"H~train" size 40000x10240
HUL_train_compl_tmp_mean = load('HUL_train_compl_tmp_mean.mat').HUL_train_compl_tmp_mean; %"muy" size 1x10240
HUL_train_compl = load('HUL_train_compl.mat').HUL_train_compl; %"Htrain" size 40000x10240
HDL_test_compl_tmp = load('HDL_test_compl_tmp.mat').HDL_test_compl_tmp; %"H~test" size 40000x10240
HDL_test_compl = load('HDL_test_compl.mat').HDL_test_compl; %"Htest" size 40000x10240

disp('Data loaded successfully.');

% Sau khi tải dữ liệu, bạn có thể tiếp tục các bước xử lý tiếp theo
% Ví dụ: Thực hiện các bước tiếp theo như huấn luyện mô hình, v.v.



%% Training with CsiNet

fprintf('Training with CsiNet...\n')

% Thiết lập các tham số mạng
maxDelay = 160/2; % # of OFDM subcarriers
nTx = 64; % # of BS antennas
numChannels = 2; % Số kênh (real và imaginary)
compressRate = 1/16; % Tỉ lệ nén
nTrain = 40000;
nTest = 2000;

% Tạo mô hình mạng CSINet
CSINet = createCSINet(maxDelay, nTx, numChannels, compressRate);

% Phân tích kiến trúc của CSINet
analyzeNetwork(CSINet);

%% Data loading



%% Set training parameters and train the network



%% Test trained CSINet



