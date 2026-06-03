clc;
clear;
close all;

%% Selezione dei file .fig
[fileNames, pathName] = uigetfile('*.fig', ...
    'Seleziona uno o più file FIG', ...
    'MultiSelect', 'on');

% Controllo selezione
if isequal(fileNames,0)
    disp('Nessun file selezionato.');
    return;
end

% Se viene selezionato un solo file
if ischar(fileNames)
    fileNames = {fileNames};
end

nFiles = length(fileNames);

%% Cartella di salvataggio
saveFolder = fullfile(pathName, 'normalized_plots');

if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

%% Richiesta intervallo asse X
prompt = {'Inserisci X minimo:', 'Inserisci X massimo:'};
dlgtitle = 'Intervallo asse X';
dims = [1 35];
definput = {'0','100'};

answer = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(answer)
    disp('Operazione annullata.');
    return;
end

xMin = str2double(answer{1});
xMax = str2double(answer{2});

%% Variabili
allData = cell(nFiles,1);
maxDiffs = zeros(nFiles,1);

globalMaxDiff = -inf;

%% Lettura file e calcolo differenze
for i = 1:nFiles
    
    figPath = fullfile(pathName, fileNames{i});
    
    % Apri figura invisibile
    fig = openfig(figPath, 'invisible');
    
    % Trova assi
    ax = findobj(fig, 'Type', 'axes');
    
    % Trova linee
    lines = findobj(ax, 'Type', 'line');
    
    if isempty(lines)
        warning('Nessuna curva trovata in %s', fileNames{i});
        close(fig);
        continue;
    end
    
    % Prima curva
    xData = get(lines(1), 'XData');
    yData = get(lines(1), 'YData');
    
    % Selezione intervallo X
    idx = (xData >= xMin) & (xData <= xMax);
    
    xSel = xData(idx);
    ySel = yData(idx);
    
    if isempty(xSel)
        warning('Nessun dato nell''intervallo per %s', fileNames{i});
        close(fig);
        continue;
    end
    
    % Delta massimo
    yDiff = max(ySel) - min(ySel);
    
    maxDiffs(i) = yDiff;
    
    % Aggiornamento massimo globale
    if yDiff > globalMaxDiff
        globalMaxDiff = yDiff;
    end
    
    % Salvataggio dati
    allData{i}.x = xSel;
    allData{i}.y = ySel;
    allData{i}.name = fileNames{i};
    
    close(fig);
end

%% Plot finale con stessa scala Y
for i = 1:nFiles
    
    if isempty(allData{i})
        continue;
    end
    
    x = allData{i}.x;
    y = allData{i}.y;
    
    % Centro verticale del segnale
    yCenter = (max(y) + min(y))/2;
    
    % Limiti asse Y
    yMinPlot = yCenter - globalMaxDiff/2;
    yMaxPlot = yCenter + globalMaxDiff/2;
    
    %% Creazione figura
    figNew = figure;
    
    % Dimensioni figura
    set(figNew, 'Position', [100 100 1400 220]);
    
    %% Plot
    plot(x, y, 'r', 'LineWidth', 1);
    
    grid on;
    
    xlim([xMin xMax]);
    ylim([yMinPlot yMaxPlot]);
    
    xlabel('time [s]', 'FontSize', 12);
    ylabel('Temperature [°C]', 'FontSize', 12);
    
    set(gca, 'FontSize', 12);
    
    title(sprintf('%s | Delta Y = %.3f', ...
        allData{i}.name, ...
        maxDiffs(i)), ...
        'FontSize', 12);
    
    %% Salvataggio FIG
    
    % Nome file senza estensione
    [~, baseName, ~] = fileparts(allData{i}.name);
    
    % Nome finale
    % Percorsi output
    pngName = fullfile(saveFolder, [baseName '_.png']);
    
    % Salva PNG ad alta risoluzione
    exportgraphics(figNew, pngName, 'Resolution', 300);
    figName = fullfile(saveFolder, [baseName '_.fig']);
    
    % Salvataggio
    savefig(figNew, figName);
    
end

%% Output finale
disp('----------------------------------');
disp('Differenze massime trovate:');

for i = 1:nFiles
    fprintf('%s --> Delta Y = %.5f\n', ...
        fileNames{i}, maxDiffs(i));
end

fprintf('\nMassima differenza globale = %.5f\n', globalMaxDiff);

fprintf('\nGrafici salvati in:\n%s\n', saveFolder);