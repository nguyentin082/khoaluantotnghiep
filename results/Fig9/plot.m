clc; clear;

% Các giá trị giả định cho sum rate với các mô hình học máy khác nhau
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];

% Đường dẫn tới thư mục chứa các tệp tin
folder_path = 'Np=400/';

% LOAD
PCA_eta16 = zeros(1, length(B_values));
PCA_eta32 = zeros(1, length(B_values));
PCA_eta64 = zeros(1, length(B_values));

for index = 1:length(B_values)
    filename = sprintf('%s(numparas)CR16-BTot%d.mat', folder_path, B_values(index));
    PCA_eta16(index) = load(filename).N_O;
end
for index = 1:length(B_values)
    filename = sprintf('%s(numparas)CR32-BTot%d.mat', folder_path, B_values(index));
    PCA_eta32(index) = load(filename).N_O;
end
for index = 1:length(B_values)
    filename = sprintf('%s(numparas)CR64-BTot%d.mat', folder_path, B_values(index));
    PCA_eta64(index) = load(filename).N_O;
end

% Vẽ biểu đồ
figure;
hold on;

semilogy(B_values, PCA_eta16, '-^', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta=16');
semilogy(B_values, PCA_eta32, '-^', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta=32');
semilogy(B_values, PCA_eta64, '-^', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta=64');

% Định dạng biểu đồ
xlabel('Feedback Length B');
ylabel('Number of offloaded model parameters');
title('Average Sum Rate vs. Feedback Length B');
legend('show');
grid on;

% Đặt các giá trị trên trục y và thiết lập thang đo logarithmic
set(gca, 'YScale', 'log');
ylim([10^5 10^7]);

% Chỉ hiển thị các giá trị B trên trục x
set(gca, 'XTick', B_values);

hold off;
