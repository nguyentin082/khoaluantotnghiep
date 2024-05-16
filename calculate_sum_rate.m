function sum_rate_vs_snr = plot_sum_rate_vs_snr(SNR_dB_range, B_values, H_true, H_reconstructed)
    % SNR_dB_range: dải giá trị SNR theo dB
    % B_values: các giá trị của B
    % H_true: ma trận kênh thực tế 64x160x2000 (ground truth)
    % H_reconstructed: cell array chứa các ma trận kênh được tái tạo từ thuật toán học máy tương ứng với mỗi B

    % Định nghĩa các tham số
    numUsers = 8;
    numAntennas = size(H_true, 1);
    numSubcarriers = size(H_true, 2);
    numSamples = size(H_true, 3);
    sum_rate_vs_snr = zeros(length(SNR_dB_range), length(B_values) + 1);
    
    % Duyệt qua các giá trị của B
    for b_idx = 1:length(B_values)
        H_reconstructed_B = H_reconstructed{b_idx};  % Lấy ma trận kênh tương ứng với B hiện tại
        
        % Duyệt qua các giá trị SNR
        for snr_idx = 1:length(SNR_dB_range)
            SNR_dB = SNR_dB_range(snr_idx);
            SNR_linear = 10^(SNR_dB/10);
            sum_rate = 0;

            % Tính toán sum rate cho mỗi SNR và B
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
                sum_rate_vs_snr(snr_idx, end) = sum_rate_vs_snr(snr_idx, end) + rate_true;
            end
            sum_rate_vs_snr(snr_idx, b_idx) = sum_rate / numSamples;
            sum_rate_vs_snr(snr_idx, end) = sum_rate_vs_snr(snr_idx, end) / numSamples;  % Sum rate with perfect CSI
        end
    end
    
    % Vẽ biểu đồ
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

function P_alloc = water_filling(H, SNR_linear)
    % Implement the water-filling algorithm to allocate power across the channels
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
end
