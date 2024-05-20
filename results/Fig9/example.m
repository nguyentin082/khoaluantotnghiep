% Các giá trị giả định cho sum rate với các mô hình học máy khác nhau
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];

% Giá trị sum rate giả định cho các mô hình học máy (đơn vị: bits/channel use)
AE128 = [10, 15, 18, 20, 22, 23, 24];
AE256 = [12, 17, 20, 22, 24, 25, 26];
AE512 = [14, 18, 22, 24, 26, 27, 28];
AE1024 = [15, 19, 23, 25, 27, 28, 29];
CsiNetPro128 = [9, 14, 17, 19, 21, 22, 23];
CsiNetPro256 = [11, 16, 19, 21, 23, 24, 25];
CsiNetPro512 = [13, 17, 21, 23, 25, 26, 27];
CsiNetPro1024 = [14, 18, 22, 24, 26, 27, 28];
PCA_eta16 = [13, 17, 21, 23, 25, 26, 27];
PCA_eta32 = [12, 16, 20, 22, 24, 25, 26];
PCA_eta64 = [11, 15, 19, 21, 23, 24, 25];

% Vẽ biểu đồ
figure;
hold on;
plot(B_values, AE128, '-o', 'LineWidth', 1.5, 'DisplayName', 'AE128');
plot(B_values, AE256, '-o', 'LineWidth', 1.5, 'DisplayName', 'AE256');
plot(B_values, AE512, '-o', 'LineWidth', 1.5, 'DisplayName', 'AE512');
plot(B_values, AE1024, '-o', 'LineWidth', 1.5, 'DisplayName', 'AE1024');
plot(B_values, CsiNetPro128, '-s', 'LineWidth', 1.5, 'DisplayName', 'CsiNetPro128');
plot(B_values, CsiNetPro256, '-s', 'LineWidth', 1.5, 'DisplayName', 'CsiNetPro256');
plot(B_values, CsiNetPro512, '-s', 'LineWidth', 1.5, 'DisplayName', 'CsiNetPro512');
plot(B_values, CsiNetPro1024, '-s', 'LineWidth', 1.5, 'DisplayName', 'CsiNetPro1024');
plot(B_values, PCA_eta16, '-^', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta=16');
plot(B_values, PCA_eta32, '-^', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta=32');
plot(B_values, PCA_eta64, '-^', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta=64');

% Định dạng biểu đồ
xlabel('Feedback Length B');
ylabel('Average Sum Rate (bits/channel use)');
title('Average Sum Rate vs. Feedback Length B');
legend('show');
grid on;
hold off;
