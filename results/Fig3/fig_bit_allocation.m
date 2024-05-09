clear; clc;

% Load data
Bs{1} = load('bitAllocation-BTot512-CR16.mat').Bs;
Bs{2} = load('bitAllocation-BTot1024-CR16.mat').Bs;
Bs{3} = load('bitAllocation-BTot1536-CR16.mat').Bs;
Bs{4} = load('bitAllocation-BTot2048-CR16.mat').Bs;

% Create subplots with larger figure window
figure('DefaultAxesFontSize',14);
set(gcf, 'Position', get(0, 'Screensize')); % Maximize figure window

for i = 1:numel(Bs)
    subplot(2, 2, i);
    area(Bs{i}, 'LineWidth', 1.5); % Change to area style plot
    title(['BTot = ' num2str(512*i)]);
    xlabel('Principal components');
    ylabel('Bits');
    xlim([1 numel(Bs{i})]); % Set x-axis limits to fit the data
    grid on; % Turn on grid
end

sgtitle('Bit Allocation');
