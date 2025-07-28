% Percorsi delle cartelle principali
cartellaA = '2025May28';
cartellaB = '2025May29';

% Definizione dell'intervallo [m1, m2] per le cartelle in B
m1 = 4189; % <-- modifica questi valori
m2 = 10;

% Ottieni elenco delle cartelle in A
sottocartelleA = dir(fullfile(cartellaA, '*'));
sottocartelleA = sottocartelleA([sottocartelleA.isdir] & ~ismember({sottocartelleA.name}, {'.', '..'}));

% Filtra solo quelle con nomi numerici
nomiNumericiA = cellfun(@(x) ~isempty(regexp(x, '^\d+$', 'once')), {sottocartelleA.name});
numeriA = str2double({sottocartelleA(nomiNumericiA).name});
n = max([numeriA, 0]); % massimo numero in A, oppure 0 se non ce ne sono

% Spostamento e rinomina cartelle da B ad A
for i = m1:m2
    nomeOrigine = fullfile(cartellaB, num2str(i));
    nuovoNome = fullfile(cartellaA, num2str(n + (i - m1) + 1));

    if isfolder(nomeOrigine)
        movefile(nomeOrigine, nuovoNome);
        fprintf('Spostata %s in %s\n', nomeOrigine, nuovoNome);
    else
        warning('Cartella %s non trovata', nomeOrigine);
    end
end