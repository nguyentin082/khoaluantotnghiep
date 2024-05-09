clear; clc;

% Load rho data
configs = {'BTot1024Na32Nc80', 'BTot1024Na32Nc160', 'BTot1024Na64Nc80', 'BTot1024Na64Nc160', ...
           'BTot512Na32Nc80', 'BTot512Na32Nc160', 'BTot512Na64Nc80', 'BTot512Na64Nc160'};
for i = 1:numel(configs)
    rho{i} = load(['rho-' configs{i} '-CR16.mat']).rho;
end

% Plot settings
LineW = 1.5;
figure('DefaultAxesFontSize', 14);
hold on;

% Define custom colors for each line
customColors = [0, 0, 0;      % Black
                0, 0, 1;      % Blue
                0, 0.7, 0;    % Green
                1, 0, 0;      % Red
                1, 0, 1;      % Magenta
                1, 0.5, 0;    % Orange
                0, 0.75, 0.75;% Cyan
                0.75, 0, 0.75;% Purple
               ];

% Plot CDFs with custom colors
for i = 1:numel(configs)
    if contains(configs{i}, '512')
        p(i) = cdfplot(10*log10(1 - rho{i}));
        set(p(i), 'LineWidth', LineW, 'DisplayName', strrep(configs{i}, 'BTot', 'B = '), ...
                  'LineStyle', '--', 'Color', customColors(i, :));
    else
        p(i) = cdfplot(10*log10(1 - rho{i}));
        set(p(i), 'LineWidth', LineW, 'DisplayName', strrep(configs{i}, 'BTot', 'B = '), ...
                  'Color', customColors(i, :));
    end
end

% Customize plot
set(gca, 'XLim', [-22, 0], 'XTick', -22:2:0);
xlabel('10log_{10}(1-\rho)');
ylabel('CDF');
legend(p, 'Location', 'southeast');
title('');
xtickangle(0);

% Get the legend handle
lgd = findobj(gcf, 'Type', 'Legend');

% Process legend text
for i = 1:numel(lgd.String)
    lgd.String{i} = regexprep(lgd.String{i}, 'B = (\d+)', 'B = $1,'); % Add comma after B =
    lgd.String{i} = strrep(lgd.String{i}, 'Na', ' Na = '); % Add Na =
    lgd.String{i} = strrep(lgd.String{i}, 'Nc', ', Nc = '); % Add Nc =
end

% Save plot
saveas(gcf, '(differentBtotNaNc)cdf-rho-CR16.png');
