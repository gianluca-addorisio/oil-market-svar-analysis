%% GUI per visualizzare le serie trasformate
clear; clc;
load('clean_data.mat','All','All_d');   % <== CARICO ANCHE All per visualizzarle (test)

vars = All_d.Properties.VariableNames;

f = figure('Name','Visualizzatore Serie Mensili','NumberTitle','off','Visible','on');
movegui(f,'center');

uicontrol('Style','text','String','Scegli variabile:','FontSize',11,...
    'Position',[40 490 120 20]);



popup = uicontrol('Style','popupmenu','Position',[170 490 200 25],...
    'String',vars,'Callback',@plotSelection);

% ===== Bottone per plottare OCSE NON differenziata (livello) - x analisi grafica =====
uicontrol('Style','pushbutton',...
    'String','Plot All (base 100)',...
    'FontSize',10,...
    'Position',[400 490 150 25],...
    'Callback',@plotAll_base100);

% ===== Bottone per plottare TUTTE le serie differenziate log (All_d) =====
uicontrol('Style','pushbutton',...
    'String','Plot All (DL)',...
    'FontSize',10,...
    'Position',[570 490 150 25],...
    'Callback',@plotAll_DL);

uicontrol('Style','pushbutton',...
    'String','OCSE vs REA (Z-score)',...
    'FontSize',10,...
    'Position',[910 490 170 25],...
    'Callback',@plot_OCSE_REA_zscore);
uicontrol('Style','pushbutton',...
    'String','OCSE – REA (Spread)',...
    'FontSize',10,...
    'Position',[1090 490 170 25],...
    'Callback',@plot_OCSE_REA_spread);




% Assi principali per le serie trasformate
ax = axes('Parent',f,'Position',[0.1 0.1 0.85 0.7]);
plotSelection([],[]);  % disegna la prima serie di default

function plotSelection(~,~)
    S = evalin('base','All_d');
    vars = S.Properties.VariableNames;
    popup = evalin('base','popup');

    idx = get(popup,'Value');
    varName = vars{idx};

    t = S.Properties.RowTimes;
    y = S.(varName);

    ax = evalin('base','ax');
    plot(ax, t, y, 'LineWidth',1.5,'Color',[1.0 0.5 0.0]);

    % === Etichette serie ===
    title(ax, varName,'FontSize',15,'Color','w');
    xlabel(ax, 'Tempo','FontSize',12,'Color','w'); 
    ylabel(ax, varName,'FontSize',12,'Color','w'); % <-- DINAMICO

    % === Formato asse tempi ===
    ax.XTickLabelRotation = 45;
    grid(ax,'on');
end


%% --- Funzione callback: ---
function plotAll_base100(~,~)

    All = evalin('base','All');   % timetable completa

    % Variabili da escludere - al momento non è previsto
    excludeVars = {'FFR','CPI'};

    % Variabili incluse
    vars = All.Properties.VariableNames;
    vars = setdiff(vars, excludeVars, 'stable');

    t = All.Time;

    % === FIGURE ===
    f = figure('Name','Serie originali – Base 100 ', ...
               'NumberTitle','off', ...
               'Color','w');       % sfondo finestra BIANCO

    ax = axes('Parent',f);
    hold(ax,'on');

    % === SFONDO ===
    ax.Color = 'w';

    % font pulito
    set(ax, ...
        'Box','on', ...
        'FontName','Arial', ...
        'FontSize',12, ...
        'LineWidth',1.2, ...
        'XColor','k', ...
        'YColor','k');

    % Colori linee puliti
    colors = [
        0 0 0;          % nero
        0.2 0.2 0.8;    % blu
        0.8 0.1 0.1;    % rosso
        0.1 0.5 0.1     % verde
    ];

    legendLabels = cell(1, numel(vars));

    % === PLOT ===
    for i = 1:numel(vars)
        col = All.(vars{i});
        y = (col / col(1)) * 100;

        c = colors(min(i,size(colors,1)),:);

        plot(ax, t, y, 'LineWidth', 2, 'Color', c);

        legendLabels{i} = vars{i};
    end

    % Linea base 100
    yline(ax, 100, '--k', 'Base 100', ...
        'LineWidth',1, ...
        'LabelHorizontalAlignment','right', ...
        'LabelVerticalAlignment','bottom');

    % Griglia
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridColor = [0.8 0.8 0.8];  % grigio chiaro
    ax.GridAlpha = 0.4;

    % Titoli e assi
    title(ax, 'Serie originali (livello) – Base 100', 'FontSize',14, 'Color','k');
    xlabel(ax, 'Tempo', 'FontSize',12, 'Color','k');
    ylabel(ax, 'Indice (Base 100)', 'FontSize',12, 'Color','k');

    % Legenda
    lg = legend(ax, legendLabels, 'Location','northwest');
    set(lg, 'TextColor','k', 'Box','off');

end



%% --- Funzione callback: WTI vs singoli regressori (diff(log)) ---
function plotAll_DL(~,~)

    % Timetable trasformata
    All_d = evalin('base','All_d');

    allVars = All_d.Properties.VariableNames;
    t       = All_d.Properties.RowTimes;

    % "Nomi logici" (come li intendi tu)
    depBase  = 'WTI';                 % variabile dipendente logica
    regBases = {'Prod','Inv','OCSE'};  % regressori logici

    % Trova in All_d il nome effettivo che corrisponde a 'WTI'
    depVar = findVarInAllD(allVars, depBase);
    if isempty(depVar)
        warning('Non trovo nessuna variabile in All_d che assomigli a "%s".', depBase);
        disp('Variabili disponibili in All_d:');
        disp(allVars');
        return;
    end

    % Trova i nomi effettivi dei regressori
    regVars = cell(size(regBases));
    for k = 1:numel(regBases)
        regVars{k} = findVarInAllD(allVars, regBases{k});
        if isempty(regVars{k})
            warning('Non trovo nessuna variabile in All_d che assomigli a "%s".', regBases{k});
            disp('Variabili disponibili in All_d:');
            disp(allVars');
            return;
        end
    end

    % Colori per dipendente vs regressore
    colDep = [0.2 0.2 0.8];   % blu per WTI
    colReg = [0.8 0.1 0.1];   % rosso per regressore

    % Ciclo sui regressori: una figura per coppia
    for k = 1:numel(regVars)

        regVar = regVars{k};
        regBase = regBases{k};

        % === FIGURE ===
        f = figure('Name', sprintf('diff(log) – %s vs %s', depBase, regBase), ...
                   'NumberTitle', 'off', ...
                   'Color', 'w');  % sfondo finestra BIANCO

        ax = axes('Parent', f);
        hold(ax, 'on');

        % === SFONDO / STILE ===
        ax.Color = 'w';
        set(ax, ...
            'Box', 'on', ...
            'FontName', 'Arial', ...
            'FontSize', 12, ...
            'LineWidth', 1.2, ...
            'XColor', 'k', ...
            'YColor', 'k');

        % Serie
        y_dep = All_d.(depVar);
        y_reg = All_d.(regVar);

        % Plot WTI (dipendente)
        plot(ax, t, y_dep, 'LineWidth', 1.8, 'Color', colDep);

        % Plot regressore
        plot(ax, t, y_reg, 'LineWidth', 1.5, 'Color', colReg);

        % Griglia
        ax.XGrid = 'on';
        ax.YGrid = 'on';
        ax.GridColor = [0.8 0.8 0.8];
        ax.GridAlpha = 0.4;

        % Titoli e assi
        title(ax, sprintf('Serie trasformate – diff(log): %s (%s) vs %s (%s)', ...
              depBase, depVar, regBase, regVar), ...
              'FontSize', 14, 'Color', 'k');

        xlabel(ax, 'Tempo (mesi)', 'FontSize', 12, 'Color', 'k');
        ylabel(ax, 'Crescita logaritmica mensile (diff log)', ...
               'FontSize', 12, 'Color', 'k');

        % Formato asse temporale
        ax.XTickLabelRotation = 45;
        try
            ax.XAxis.TickLabelFormat = 'MMM yyyy';
        catch
            % versioni MATLAB vecchie: ignora
        end

        % Legenda: nome logico + nome effettivo
        lg = legend(ax, ...
            {sprintf('%s (%s)', depBase, depVar), ...
             sprintf('%s (%s)', regBase, regVar)}, ...
            'Location', 'northwest');
        set(lg, 'TextColor', 'k', 'Box', 'off');

    end

end

%% Funzione di supporto: cerca una variabile "simile" in All_d
function varName = findVarInAllD(allVars, baseName)
    % 1) prova match esatto (case-insensitive)
    idx = strcmpi(allVars, baseName);
    if any(idx)
        varName = allVars{find(idx,1)};
        return;
    end

    % 2) prova variabili che contengono il nome (dlog_WTI, WTI_d, ecc.)
    idx = contains(lower(allVars), lower(baseName));
    if any(idx)
        varName = allVars{find(idx,1)};
        return;
    end

    % 3) non trovato
    varName = '';
end


%% ============================================================
% STYLISED FACTS – RELAZIONI TRA VARIABILI (Z-SCORE, 3 PANEL)
% Tutte le serie standardizzate: (x - mean) / std
%% ============================================================

fprintf('Generating Stylised Facts (Z-score panels)...\n');

% --- Estrazione serie in livello ---
WTI  = All.WTI_real;
OECD = All.OCSE;
Prod = All.Production;
Inv  = All.Inventories;
t    = All.Time;

% --- Standardizzazione (Z-score) ---
WTI_z  = (WTI  - mean(WTI,  'omitnan')) ./ std(WTI,  'omitnan');
OECD_z = (OECD - mean(OECD, 'omitnan')) ./ std(OECD, 'omitnan');
Prod_z = (Prod - mean(Prod, 'omitnan')) ./ std(Prod, 'omitnan');
Inv_z  = (Inv  - mean(Inv,  'omitnan')) ./ std(Inv,  'omitnan');

% ============================================================
% FIGURA
% ============================================================
fig_z = figure('Color','w','Position',[200 200 1200 900]);
set(fig_z,'InvertHardcopy','off');

% Stile globale "paper/pitch"
set(groot, ...
    'defaultAxesFontName','Helvetica', ...
    'defaultAxesFontSize',12, ...
    'defaultAxesLineWidth',1, ...
    'defaultLineLineWidth',1.5, ...
    'defaultAxesXColor','k', ...
    'defaultAxesYColor','k', ...
    'defaultAxesBox','on', ...
    'defaultAxesColor','w', ...
    'defaultLegendTextColor','k');

%% 1) WTI vs OECD (Z-score)
subplot(3,1,1);
plot(t, WTI_z,  'k', 'LineWidth',1.2); hold on;
plot(t, OECD_z, 'Color',[0 0.35 0.8], 'LineWidth',1.5);
yline(0,'k:');   % linea media

title('OECD Activity and Real WTI: Business-Cycle Co-Movement', ...
      'FontWeight','bold', 'Color', 'k');
ylabel('Z-score');

grid on;
ax = gca;
ax.YGrid     = 'on';
ax.XGrid     = 'off';
ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.25;

legend({'Real WTI','OECD Activity'}, ...
       'Location','northwest', ...
       'Box','off');

%% 2) WTI vs Global Production (Z-score)
subplot(3,1,2);
plot(t, WTI_z,  'k', 'LineWidth',1.2); hold on;
plot(t, Prod_z, 'Color',[0.8 0 0], 'LineWidth',1.5);
yline(0,'k:');

title('Global Oil Production and Real WTI: Slow Supply Adjustment', ...
      'FontWeight','bold', 'Color', 'k');
ylabel('Z-score');

grid on;
ax = gca;
ax.YGrid     = 'on';
ax.XGrid     = 'off';
ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.25;

legend({'Real WTI','Production'}, ...
       'Location','northwest', ...
       'Box','off');

%% 3) WTI vs Inventories (Z-score)
subplot(3,1,3);
plot(t, WTI_z, 'k', 'LineWidth',1.2); hold on;
plot(t, Inv_z, 'Color',[0.6 0 0.6], 'LineWidth',1.5);
yline(0,'k:');

title('Inventories and Real WTI: Precautionary Build-Up under Uncertainty', ...
      'FontWeight','bold', 'Color', 'k');
ylabel('Z-score');

grid on;
ax = gca;
ax.YGrid     = 'on';
ax.XGrid     = 'off';
ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.25;

legend({'Real WTI','Inventories'}, ...
       'Location','northwest', ...
       'Box','off');

% ============================================================
% SALVATAGGIO
% ============================================================
outdir = fullfile(pwd, 'figures');
if ~exist(outdir,'dir'); mkdir(outdir); end

outfile = fullfile(outdir, 'stylised_facts_Zscore_panels.png');
saveas(fig_z, outfile);
fprintf('Z-score panels figure saved as %s\n', outfile);


function plot_OCSE_REA_zscore(~,~)

    All = evalin('base','All');

    % --- FILTRO TEMPORALE: dal 1 gennaio 2010 ---
    t0 = datetime(2010,1,1);
    mask = All.Time >= t0;

    t    = All.Time(mask);
    ocse = All.OCSE(mask);
    rea  = All.REA(mask);

    % --- Z-SCORE ---
    ocse_z = (ocse - mean(ocse,'omitnan')) ./ std(ocse,'omitnan');
    rea_z  = (rea  - mean(rea,'omitnan')) ./ std(rea,'omitnan');

    % === FIGURA ===
    f = figure('Name','OCSE vs REA – Z-score (dal 2010)',...
               'NumberTitle','off',...
               'Color','w');

    ax = axes('Parent',f); 
    hold(ax,'on');

    % Stile asse
    set(ax,'Box','on','FontName','Arial','FontSize',12,...
           'LineWidth',1.2,'XColor','k','YColor','k','Color','w');

    % Linee
    plot(ax, t, ocse_z, 'k-',  'LineWidth',1.8);
    plot(ax, t, rea_z,  'k--', 'LineWidth',1.8);

    yline(ax,0,'--k','LineWidth',0.8);

    % Griglia
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridColor = [0.85 0.85 0.85];
    ax.GridAlpha = 0.3;

    % Etichette
    title(ax,'OCSE vs REA – Standardised (Z-score) – dal 2010','Color','k','FontSize',14);
    xlabel(ax,'Tempo','Color','k');
    ylabel(ax,'Z-score','Color','k');

    ax.XTickLabelRotation = 45;

    % Legenda
    l = legend(ax,{'OCSE','REA'},'Location','northwest');
    set(l,'TextColor','k','Box','off');

end
