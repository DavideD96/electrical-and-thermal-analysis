function [results, Eventi] = analisi_Nframes011_multiEvento_007_pV(frame_start, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prova: eseguo primi vicini sull'immagine originale e non ricostruita
%Date: 2023-10-12 Last modification: 2024-01-15
%6th edition of analisi_Nframes
%Author: Cristina Zuccali
%analisi_Nframes011_multiEvento_004(mtotalDT, soglia_max, soglia_min, varargin)
%
% Ricerca dei frames evento
% Ricerca degli eventi nei frames con evento
% Aggiornamento: salvataggio dei dati in struct e area totale interessanta
% dagli eventi
%
%   'mtotalDT' = matrice dei frames differenza in termoFiles_mat
%   'soglia_max' = threshold for the selection of maxima
%   'soglia_min' = threshold for the selection of minima
%
%   'varargin' : 
%       there is the possibility of smooth mdiff data
%               ('smoothing', 1) --> smoothing of mdiff data
%               ('smoothing', 0) --> mdiff is left invariate
%
%       for video production
%               ('makeVideo', 1) --> makes the video
%
%
%       for area detection
%               ('detecArea', 1) --> calculate the area, solo con il metodo
%                                       BiW (Soglia Otsu)    
%
%   ('framestates' = [max coord, max value, min coord, min value, nevento, tempo])
%   'frame_states' = is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame
%   'Eventi' = è più generale ed è una struct di tante struct (1 per frame)
%
% salva Eventi_Termo con tutti gli eventi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num = length(varargin);

%PARAMETRI DI DEFAULT
smooth = 0;
dec_centroid = 0;
video = 0;
save_results = 1;

%varagin
for k = 1:2:num
    if prod(varargin{k}=='smoothing')
        smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
    
    elseif prod(varargin{k}=='makeVideo')
        video = varargin{k+1}; % 1 = video

    elseif prod(varargin{k}=='dCentroid')
        dec_centroid = varargin{k+1}; % 1 = trova i centri di massa dei frame con evento
    end
end

%Cartella per salvataggio dati
check = exist(['ThermoResults\frStart', num2str(frame_start)]);
    if check ~= 7
        mkdir(['ThermoResults\frStart', num2str(frame_start)]);
    end

    path = [pwd,'\ThermoResults\frStart', num2str(frame_start), '\',];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CARICA DATI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
cd termoFiles_mat 
    mtotalDT = load("mtotalDT.mat");
    mtotalDT = cell2mat(struct2cell(mtotalDT));

    times = load("timesDT.mat");
    times = cell2mat(struct2cell(times));
cd ..

cd 'parameters'
ThermalParameters_ = load('ThermalParameters.mat');
ThermalParameters = ThermalParameters_.ThermalParameters;
cd ..

%global
fr_diff = ThermalParameters.fr_diff;

%Nframes = 'all';
soglia_max = ThermalParameters.soglia_max;
soglia_min = ThermalParameters.soglia_min;
Rows = ThermalParameters.Rows;
Columns = ThermalParameters.Columns;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INIZIALIZZO I PARAMETRI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRI DWT
wname = 'db4';
level =1;

%ARRAY PER SALVARE I DATI
%(coord, value)
Nframes = length(mtotalDT(1,1,:)) - frame_start;
framestates = zeros(Nframes,6);

%VARIABILI VIDEO
if video == 1
    rallenty = 15;
    video_name = strcat('video.avi');

    vidObj = VideoWriter(append(path,video_name));
    vidObj.Quality = 100; % max (credo)
    vidObj.FrameRate = 30/rallenty; %i dati della termocamera sono a 30 Hz
    open(vidObj);


    video_length = Nframes*2;
    video_frameRate = 60;
    video_times = zeros(video_length,1);

    for i=1:video_length
        video_times(i) = (i-1)*1/video_frameRate;
    end

    f = figure('position',[200 100 1000 500]);
    load('ThermoColorMap1.mat');
end

%area
area_massimi = zeros(Nframes, 1);
area_minimi = zeros(Nframes, 1);

%VARIABILI CENTRO DI MASSA
if dec_centroid == 1
    CM = zeros(Nframes,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DETECTION E ANALISI DATI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 0 : Nframes - 1
    %stringa per salvataggio dati
    fname = ['frame', num2str(frame_start+ i + fr_diff)];
    
    %calcolo tempo
    framestates(i+1, 6) = times(1, frame_start + i);

    %decomposizione
    mdiff = mtotalDT(:,:, frame_start + i);
    [C, S] = wavedec2(mdiff, level, wname);
    
    %ricostruzione immagine
    imrec = wrcoef2("a",C,S,wname,level);
    %coeff_DWT.(fname) = {C, S};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %array massimi e minimi
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [max_hotspot, min_hotspot] = hotspot_4(imrec, soglia_max, soglia_min, 'smoothing', smooth); % trovo tutti i pixel sopra soglia
    
    %max_hotspot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Controllo primi vicini assoluti
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %MASSIMO ASSOLUTO
    %controllo se ci sono dati o è vuota
    if isempty(max_hotspot) == 0
        %seleziono massimo assoluto
        max_hotspot = sortrows(max_hotspot, 2, 'descend'); %2 è la colonna dei valori: ordino in base al più alto
        framestates(i+1, 1) = max_hotspot(1,1);
        framestates(i+1, 2) = max_hotspot(1,2);
        
        %primi vicini
        point_state_max = primi_vicini(max_hotspot(1,:), 1, mdiff); %faccio primi vicini su 1 candidato evento

    else   
        framestates(i+1, 1) = 0;
        framestates(i+1, 2) = 0;
        point_state_max = 0;
    end
    
    %MINIMO ASSOLUTO
    %controllo se ci sono dati o è vuota
    if isempty(min_hotspot) == 0
        %seleziono minimo assoluto
        min_hotspot = sortrows(min_hotspot, 2, 'ascend');
        framestates(i+1, 3) = min_hotspot(1,1);
        framestates(i+1, 4) = min_hotspot(1,2);
        
        %primi vicini
        point_state_min = primi_vicini(min_hotspot(1,:), 0,  mdiff);
       
    else
        framestates(i+1, 3) = 0;
        framestates(i+1, 4) = 0;
        point_state_min = 0;
    end
    
    if point_state_max == 1 | point_state_min == 1
        framestates(i+1, 5) = 1;
        
    else
        framestates(i+1,5) = 0;
        
    end
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Cerco altri eventi nello stesso frame e ne calcolo l'area
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           tutti i sopra soglia trovati,   stato: (1 o 0),   immagine ricostruita e originale
    [max_evento, min_evento, area_max, area_min, imsov] = detection_multiEvento_002_pV(max_hotspot, min_hotspot, point_state_max, point_state_min,imrec, mdiff, Rows, Columns);

    %calcolo area
    for k = 1 : length(area_max(:,1))
        area_massimi(i+1, 1) = area_massimi(i+1, 1) + area_max(k,1);
    end

    for k = 1 : length(area_min(:,1))
        area_minimi(i+1, 1) = area_minimi(i+1, 1) + area_min(k,1);
    end
    
    %salvataggio dati in struct
    Eventi.(fname) = struct('tempo', times(1, frame_start + i),'massimi', {max_evento}, 'minimi', {min_evento}, 'area_max', area_massimi(i+1,1), 'area_min', area_minimi(i+1,1), 'num_evento', 0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Video con mappa a colori 2d e stampa dei punti in cui ho un evento
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if video == 1
        set(gcf, 'Color','white');
        [zmin, zmax] = bounds(imrec, "all"); %metto imrec o mdiff per i limiti??????
        Tmax = max(zmax, abs(zmin));
        
        subplot(1,2,1)
        hold on
            imagesc(imrec);
            set(subplot(1,2,1), 'YDir', 'normal')
            clim(subplot(1,2,1), [-Tmax Tmax]);
            colormap(subplot(1,2,1), cm);
            colorbar (subplot(1,2,1));
    
            xlabel('[n° pixel]');
            ylabel('[n° pixel]');
            title('Temperature difference [°C]');
    
            tempo = append(num2str(framestates(i+1, 6)), ' s');
            annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');
    
            %se state del frame è 1 disegno punto di massimo e/o minimo            
            if point_state_max == 1 | point_state_min == 1
                evento = append('EVENTO');
                annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', evento, 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');
    
                [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    
                if point_state_max ~= 0 %%se c'è un massimo allora plotta il punto
                    for j = 1 : length(max_evento(:,1))
                        plot(data_x(max_evento(j,1)), data_y(max_evento(j,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'white')
                    end
                end
    
                if point_state_min ~= 0
                    for j = 1 : length(min_evento(:,1))
                        plot(data_x(min_evento(j,1)), data_y(min_evento(j,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black','MarkerEdgeColor', 'white')
                    end  
                end
                hold off


                %diesgno area
                subplot(1,2,2)
                hold on
                    imagesc(imsov);
                    colormap(subplot(1,2,2), 'gray');
                    colorbar(subplot(1,2,2));
        
                    xlabel('[n° pixel]');
                    ylabel('[n° pixel]');
                    title('Area event detection');
                    
                    if point_state_max ~= 0 %%se c'è un massimo allora plotta il punto
                    for j = 1 : length(max_evento(:,1))
                        plot(data_x(max_evento(j,1)), data_y(max_evento(j,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'red')
                    end

                    end
        
                    if point_state_min ~= 0
                        for j = 1 : length(min_evento(:,1))
                            plot(data_x(min_evento(j,1)), data_y(min_evento(j,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue')
                        end  
                    end
                    
                hold off
            end
    
        %salvo il frame
        frame = getframe(gcf);
        writeVideo(vidObj, frame);
        delete(findall(gcf,'type','annotation'));
        clf(gcf);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calcolo CM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if dec_centroid == 1
        if framestates(i+1, 5) ~= 0
            [CM(i+1, 1), CM(i+1, 2)] = calculate_CM(imrec, Rows, Columns);
    
        elseif framestates(i+1, 5) == 0 
            CM(i+1, 1) = 0;
            CM(i+1, 2) = 0;
        end
    end

    clear mdiff;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Raggruppamento frames che detectano lo stesso evento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variabile per contare gli eventi e raggrupparli
    n_evento = 0;
    state_max = 0;
    state_min = 0;
    
    fname = ['frame', num2str(frame_start + fr_diff)];
    if Eventi.(fname).massimi(1,1) ~= 0 & Eventi.(fname).minimi(1,1) ~= 0
        eventi_tutti = [Eventi.(fname).massimi; Eventi.(fname).minimi];
    elseif Eventi.(fname).massimi(1,1) ~= 0
        eventi_tutti = Eventi.(fname).massimi;
    elseif Eventi.(fname).minimi(1,1) ~= 0
        eventi_tutti = Eventi.(fname).minimi;
    else
            eventi_tutti = [];
    end

    if isempty(eventi_tutti) == 0
        n_evento = 1;
    end

    for i=1:Nframes-1
        fname = ['frame', num2str(frame_start+ i + fr_diff)];
        if Eventi.(fname).massimi(1,1) ~= 0 & Eventi.(fname).minimi(1,1) ~= 0
        eventi_tutti = [Eventi.(fname).massimi; Eventi.(fname).minimi];
        elseif Eventi.(fname).massimi(1,1) ~= 0
            eventi_tutti = Eventi.(fname).massimi;
        elseif Eventi.(fname).minimi(1,1) ~= 0
            eventi_tutti = Eventi.(fname).minimi;
        else
            eventi_tutti = [];
        end

        fname_prec = ['frame', num2str(frame_start+ i + fr_diff - 1)];
        if Eventi.(fname_prec).massimi(1,1) ~= 0 & Eventi.(fname_prec).minimi(1,1) ~= 0
            eventi_tutti_prec = [Eventi.(fname_prec).massimi; Eventi.(fname_prec).minimi];
        elseif Eventi.(fname_prec).massimi(1,1) ~= 0
            eventi_tutti_prec = Eventi.(fname_prec).massimi;
        elseif Eventi.(fname_prec).minimi(1,1) ~= 0
            eventi_tutti_prec = Eventi.(fname_prec).minimi;
        else
            eventi_tutti_prec = [];
        end

        %se c'è un evento
        state = raggruppo_2eventi_002(eventi_tutti_prec, eventi_tutti, Rows, Columns);
        
        if isempty(eventi_tutti) == 0
            if state == 1
                Eventi.(fname).num_evento = n_evento;
                framestates(i+1,5) = Eventi.(fname).num_evento;
            
            elseif state == 0
                n_evento = n_evento + 1;
                framestates(i+1,5) = n_evento;
                Eventi.(fname).num_evento = n_evento;
                 framestates(i+1,5) = Eventi.(fname).num_evento;
            end
        else
            framestates(i+1,5) = 0;
            Eventi.(fname).num_evento = 0;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Salvataggi dei dati
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CHIUSURA VIDEO
    if video == 1
        close(gcf);
        close(vidObj);
    end
        
    %CENTRO DI MASSA E GRAFICO
    if dec_centroid == 1
        save('CM.mat', 'CM');
    
        %figura con mappatura CM
        figure
        hold on
            title('Position of CM');
            xlabel('[n° pixel]');
            ylim([0 Rows]);
            xlim([0 Columns]);
            ylabel('[n° pixel]');
            A = zeros(0, 2);
    
            for i = 1 : length(CM(:,1))
                if CM(i,1) ~= 0 && CM(i,2) ~= 0
                    A(end+1,:) = [CM(i,1), CM(i,2)];
                end
            end
    
            plot(A(:,1), A(:,2), '-o', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
    
            %salva figura
            CM_name = append(path,'CM_position');
            saveas( gcf , CM_name);
        hold off
    end
    
    %salva dati
    save('frames.mat', 'framestates');
   
    results = [framestates(:,6),framestates(:,1),framestates(:,3),framestates(:,2),framestates(:,4),area_massimi(:,1),area_minimi(:,1),framestates(:,5)];
    

    save("Eventi_Termo_principali.mat", 'results');
    save("results.mat", 'results');

    %salva struttura
    save("Eventi_Termo.mat", "Eventi")
end




