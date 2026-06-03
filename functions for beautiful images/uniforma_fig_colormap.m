function uniforma_fig_colormap()

    % =========================================================
    % SELEZIONE FILE .FIG
    % =========================================================
    [files,path] = uigetfile('*.fig', ...
        'Seleziona le figure', ...
        'MultiSelect','on');

    if isequal(files,0)
        return;
    end

    % se singolo file -> cell
    if ischar(files)
        files = {files};
    end

    nFiles = numel(files);

    % =========================================================
    % PRIMO PASSAGGIO:
    % TROVA MIN/MAX GLOBALI
    % =========================================================
    globalMin = +inf;
    globalMax = -inf;

    validFiles = {};
    validData  = {};

    fprintf('\nAnalisi figure...\n');

    for k = 1:nFiles

        filename = fullfile(path,files{k});

        try

            % apertura invisibile
            f = openfig(filename,'invisible');

            % cerca immagini
            imgObjs = findobj(f,'Type','image');

            if isempty(imgObjs)

                fprintf('SKIP (no image): %s\n',files{k});

                close(f);
                continue;

            end

            % prende prima immagine
            cdata = get(imgObjs(1),'CData');

            % verifica formato
            if ~isnumeric(cdata) || ndims(cdata) ~= 2

                fprintf('SKIP (not 2D numeric image): %s\n',files{k});

                close(f);
                continue;

            end

            localMin = min(cdata(:));
            localMax = max(cdata(:));

            globalMin = min(globalMin,localMin);
            globalMax = max(globalMax,localMax);

            validFiles{end+1} = filename;
            validData{end+1}  = cdata;

            fprintf('OK: %s\n',files{k});

            close(f);

        catch ME

            fprintf('Errore con %s\n',files{k});
            disp(ME.message);

        end

    end

    % =========================================================
    % CONTROLLO
    % =========================================================
    if isempty(validFiles)

        error('Nessuna figura valida trovata.');

    end

    fprintf('\n============================\n');
    fprintf('GLOBAL MIN = %g\n',globalMin);
    fprintf('GLOBAL MAX = %g\n',globalMax);
    fprintf('============================\n');

    % =========================================================
    % SECONDO PASSAGGIO:
    % RIPLOT + SAVE FIG + PNG
    % =========================================================
    for k = 1:numel(validFiles)

        cdata = validData{k};

        [folder,name,~] = fileparts(validFiles{k});

        % nuova figura
        f = figure(...
            'Name',[name '_'], ...
            'Color','w');

        imagesc(cdata);

        axis image;

        colormap('jet');

        colorbar;

        massimissimo = max(abs([globalMin globalMax]));
        clim([-massimissimo massimissimo]);

        title(name,'Interpreter','none');

        % =====================================================
        % NOMI FILE
        % =====================================================
        figFilename = fullfile(folder,[name '_.fig']);

        pngFilename = fullfile(folder,[name '_.png']);

        % =====================================================
        % SAVE FIG
        % =====================================================
        savefig(f,figFilename);

        % =====================================================
        % SAVE PNG
        % =====================================================
        exportgraphics(f,pngFilename,'Resolution',300);

        fprintf('Salvati:\n');
        fprintf('  %s\n',figFilename);
        fprintf('  %s\n\n',pngFilename);

    end

end