% PLOT_PASS_THROUGH_SCATTER.M
clear; clc;
load('jetfuel_pass_results.mat','WTI_hist','JF_hist','JF_hat');  % usa i nomi reali

figure;
scatter(WTI_hist, JF_hist, 15, 'filled'); hold on;
plot(WTI_hist, JF_hat, 'LineWidth', 1.5);
xlabel('WTI (USD/bbl)');
ylabel('Jet Fuel USGC (USD/bbl)');
title('Observed vs fitted Jet Fuel prices');
grid on;

print('-dpng','passthrough_scatter.png'); % oppure pdf
