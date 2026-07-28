
% Cerca tutti i file che iniziano con "trace"
files = dir('trace*');

% Ciclo su tutti i file trovati
for k = 1:length(files)

    % Carica il file
    data = load(files(k).name);

    % Recupera la variabile "trace"
    trace = data.trace;

    % Recupera le dimensioni attuali della figura 
    fig = figure;
    scaleFactor = 2.5;
    pos = get(fig, 'Position'); 
    % Ingrandisce larghezza e altezza di un fattore 2.5 
    pos(3) = pos(3) * scaleFactor; 
    pos(4) = pos(4)*0.5;
    pos(1) = pos(1)-400;
    % Imposta le nuove dimensioni 
    set(fig, 'Position', pos);

    % Plot dei dati
    plot(trace(9:15:end));

    % Titolo con il nome del file
    title(files(k).name, 'Interpreter', 'none');

    % Etichette degli assi
    xlabel('Campioni');
    ylabel('Ampiezza');

    % Salva la figura come .fig
    [~, nomeFile, ~] = fileparts(files(k).name);
    savefig(nomeFile);

    % Salva la figura anche in formato .png 
    saveas(fig, [nomeFile, '.png']);
end

