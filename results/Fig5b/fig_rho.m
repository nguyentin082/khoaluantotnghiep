clear; clc;

% Load rho data
configs = {'BTot1536Ntrain5000', 'BTot1536Ntrain3000', 'BTot1536Ntrain2000', 'BTot1536Ntrain1500', ...
           'BTot512Ntrain5000', 'BTot512Ntrain3000', 'BTot512Ntrain2000', 'BTot512Ntrain1500'};
for i = 1:numel(configs)
    rho{i} = load(['rho-' configs{i} '-CR16.mat']).rho;
end

% Plot settings
LineW = 1.5;
figure('DefaultAxesFontSize', 14);
hold on;

% Define custom colors for each line
customColors = [ 0, 0, 1;      % Blue
                0, 0.7, 0;    % Green
                1, 0.5, 0;    % Orange
                0.75, 0, 0.75;% Purple
                1, 0, 0;      % Red
                0, 0.5, 0.5;  % Teal
                0.5, 0.5, 0;  % Olive
                0, 0, 0;      % Black
               ];

p = zeros(1, numel(configs)); % Preallocate legend handles
legendEntries = cell(1, numel(configs));
for i = 1:numel(configs)
    [f, x] = ecdf(10*log10(1 - rho{i}));
    p(i) = plot(x, f, 'Color', customColors(mod(i-1, size(customColors, 1)) + 1, :), 'LineWidth', LineW);
    
    % Extract B and Ntrain values
    [tokens, ~] = regexp(configs{i}, 'BTot(\d+)Ntrain(\d+)', 'tokens', 'match');
    B_value = str2double(tokens{1}{1});  % Extracting B value
    Ntrain_value = str2double(tokens{1}{2});  % Extracting Ntrain value
    legendEntries{i} = sprintf('B = %d, Ntrain = %d', B_value, Ntrain_value);
end

% Customize plot
set(gca, 'XLim', [-23, 0], 'XTick', -22:2:0);
xlabel('10log_{10}(1-\rho)');
ylabel('CDF');
legend(p, legendEntries, 'Location', 'southeast');
title('');
xtickangle(0);

% Add grid
grid on;

% Save plot
saveas(gcf, '(differentBtotNtrain)cdf-rho-CR16.png');
