% Bước 1: Tải dữ liệu ban đầu
data = load('H_train.mat'); 
if isfield(data, 'H_train')
    H_train = data.H_train;
    disp('Data loaded successfully.');
else
    error('H_train variable not found in the file.');
end

% Kiểm tra kích thước của dữ liệu ban đầu
disp('Initial size of H_train:');
disp(size(H_train)); % Kích thước ban đầu của H_train

% Bước 2: Mở rộng dữ liệu bằng cách nhân đôi
num_repeats = 8; % Số lần lặp lại để đạt được kích thước mong muốn (5,000 x 8 = 40,000)
H_train_expanded = repmat(H_train, [1, 1, num_repeats]);

% Kiểm tra kích thước của dữ liệu sau khi mở rộng
disp('Size of H_train_expanded after replication:');
disp(size(H_train_expanded)); % Kích thước sẽ là [64 x 160 x 40,000]

% Bước 3: Lưu dữ liệu đã mở rộng (tuỳ chọn)
save('H_train_expanded.mat', 'H_train_expanded', '-v7.3');
disp('Expanded data saved successfully.');
