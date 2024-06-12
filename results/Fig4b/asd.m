clc; clear;

% Tạo các ma trận bit ngẫu nhiên (logical bits)
detected_bits = randi([0 1], 3, 3); % Tạo ma trận 4x4 với giá trị ngẫu nhiên 0 hoặc 1
bits = randi([0 1], 3, 3); % Tạo ma trận 4x4 với giá trị ngẫu nhiên 0 hoặc 1

% Tính BER
ber_true = mean(detected_bits(:) ~= bits(:)); % Tính BER bằng cách so sánh từng phần tử của hai ma trận
