%% FIT MARGINAL DISTRIBUTIONS FOR STRUCTURAL SHOCKS
clear; clc;

%% ----- Stile grafico globale -----
set(groot, ...
    'defaultFigureColor','w', ...
    'defaultAxesColor','w', ...
    'defaultAxesXColor','k', ...
    'defaultAxesYColor','k', ...
    'defaultAxesGridColor',[0.85 0.85 0.85], ...
    'defaultAxesFontName','Helvetica', ...
    'defaultAxesFontWeight','normal', ...
    'defaultAxesFontSize',12, ...
    'defaultLineLineWidth',2, ...
    'defaultLegendTextColor','k');

if ~exist('structural_shocks.mat','file')
    error('Esegui prima extract_structural_shocks.m');
end

load('structural_shocks.mat','Eps','shockLabels');

[T, n] = size(Eps);
fprintf('Numero osservazioni: %d, shock: %d\n', T, n);

distFits = cell(n,1);  % salva i fit marginali

%% ========= FIGURA 1: ISTOGRAMMI + DENSITÀ (3 PANNELLI) =========
figHist = figure('Color','w','Position',[100 100 1100 400]);
tiledlayout(figHist,1,3,"TileSpacing","compact","Padding","compact");
%% ========= FIGURA 1: ISTOGRAMMI + DENSITÀ (3 PANNELLI) =========
figHist = figure('Color','w','Position',[100 100 1100 400]);
tiledlayout(figHist,1,3,"TileSpacing","compact","Padding","compact");

% ---- Range X comune (simmetrico) per tutti gli shock ----
xAll   = Eps(:,1:3);                          % solo i 3 shock principali
maxAbs = max(abs(xAll),[],'all');             % valore assoluto massimo
maxAbs = ceil(maxAbs*10)/10;                  % arrotondo un po' verso l'alto
xLim   = [-maxAbs, maxAbs];                   % stesso range per tutti

% ---- Per allineare anche l'asse Y ----
yMax   = 0;                                   % verrà aggiornato nel loop
axHist = gobjects(3,1);                       % handler degli assi


for j = 1:3
    x = Eps(:,j);

    fprintf('\n==============================\n');
    fprintf('Shock %d: %s\n', j, shockLabels{j});
    fprintf('==============================\n');

    % Statistiche
    fprintf('Skewness = %.4f\n', skewness(x));
    fprintf('Kurtosis = %.4f\n', kurtosis(x));

    % Fit distribuzioni
    distNorm     = fitdist(x,'Normal');
    distT        = fitdist(x,'tLocationScale');
    distLogistic = fitdist(x,'Logistic');

    distFits{j} = {distNorm, distT, distLogistic};

    % ----- Pannello j: istogramma + densità -----
    nexttile;

    histogram(x,'Normalization','pdf',...
              'FaceColor',[0.82 0.82 0.82],...
              'EdgeColor',[0.3 0.3 0.3]);
    hold on;

    xg = linspace(min(x),max(x),400);
    plot(xg,pdf(distNorm,xg),'k','LineWidth',1.8);
    plot(xg,pdf(distT,xg),'b','LineWidth',1.8);
    plot(xg,pdf(distLogistic,xg),'r-.','LineWidth',1.5);

    xlabel('Shock','Color','k');
    if j == 1
        ylabel('Densità','Color','k');
    end

    title(strrep(shockLabels{j},'_',' '), ...
          'FontWeight','bold','Color','k');

    if j == 3
        lgd = legend({'Dati','Normale','t-Student','Logistica'},...
                     'Location','best','Box','off');
        set(lgd,'TextColor','k','FontWeight','bold');
    end

    grid on; box on;
end

% Se vuoi salvare direttamente la figura per la tesi:
% exportgraphics(figHist,'shock_marginals_panel.png','Resolution',300);


%% ========= FIGURA 2 (OPZIONALE): QQ-PLOT (3 PANNELLI) =========
figQQ = figure('Color','w','Position',[150 150 1100 400]);
tiledlayout(figQQ,1,3,"TileSpacing","compact","Padding","compact");

for j = 1:3
    x = Eps(:,j);

    nexttile;
    qqplot(x);
    title(['QQ-plot – ' strrep(shockLabels{j},'_',' ')], ...
          'FontWeight','bold','Color','k');
    grid on; box on;
end

% exportgraphics(figQQ,'shock_qqplots_panel.png','Resolution',300);


%% ========= Salvataggio fit =========
save('structural_shocks.mat','distFits','-append');

fprintf('\n>> Stima marginali completata.\n');
