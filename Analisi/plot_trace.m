function plot_trace(start,pulses)

files = dir('trace*');
files = files(~endsWith({files.name}, '.fig'));

    % Controlla se ci sono file
    if isempty(files)
        disp('Nessun file trovato.');
        dati = {};
        return;
    end

    % Ciclo sui file
    for k = 1:length(files)
        nomeFile = files(k).name;

        fprintf('Caricamento file: %s\n', nomeFile);

        % Carica il file
        % Usa load se sono file .mat o dati numerici
        trace = load(nomeFile);
        trace = trace.trace;
        % plot(trace)
        % title('select start')
        % pause
        % [x,y] = ginput(1);
        
        ax = figure('Position', [100, 100, 1400, 350]);

        if pulses == 1

            plot(trace(start:20:end-1));
        else

            times = linspace(1,length(trace)-start+1,length(trace)-start+1)/50;
            plot(times,trace(start:end));
        end
        grid on
        savefig(ax,[nomeFile,'.fig'])
        % Se vuoi fare elaborazioni:
        % esempio:
        % disp(dati{k});
    end

    if pulses == 1
        m = load("mtotalT.mat");
        m = m.mtotalT;
        mtotalT_reduced = m(:,:,start:20:end-1);
        save('mtotalT_reduced.mat',"mtotalT_reduced")
    end
end