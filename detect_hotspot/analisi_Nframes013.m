function [results, Rows, Columns] = analisi_Nframes013(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, method, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-12-12
%6th edition of analisi_Nframes
%Author: Cristina Zuccali
%analisi_Nframes(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%
%Added: centroid of frames with an event detected
%
% Save only the DWT coefficients and not the image
%
%   'filename' = principal part of the file name of frame (without number of frame and .CSV)
%   'Nframes' = number of frames to analyze
%   'frame_start' = number of start frame
%   'fr_diff' = difference beetwen frame to show the difference of
%               temperature (fr_diff = 2 means difference between consecutive frames)
%   'coordname' = name of file with coordinates of the wanted region
%   'soglia_max' = threshold for the selection of maxima
%   'soglia_min' = threshold for the selection of minima
%   'method' = method for the detection of the events (only 'ThreshNN'
%              implemented so far)
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
%               ('detecArea', 1) --> calculate the area
%
%       to choose the method for the spot characterization
%               ('AreaMetho', 'CWT') = it finds the 'scale' of the spot
%               ('AreaMetho', 'BiW') = binarization 
%               ('AreaMetho', 'RGS') = regional growth method
%               ('ThreshRGS', ...) for pixels selection in regional growth segmentation
%
%       to store data in ".mat" (thus avoiding to use get_Data multiple times, that is
%       time consuming):
%               ('store___T', true) stores T
%               ('store__DT', true) store delta T (mdiff)
%               ('storeEvnT', true) store events only (1 event <-> 1 frame)
%
%       to use a reference frame:
%               ('rfrcFrame', 0) do not use reference frame
%               ('rfrcFrame', 1) use the first frame before each detected 
%                                event as reference frame for the single
%                                event.
%               ('rfrcFrame', 2) use the frame indicated by 'Use_Frame' as 
%                                reference for the entire time serie. 
%
%   'frame_states' = is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num = length(varargin);

%PARAMETRI DI DEFAULT
smooth = 0;
method_area = 'BiW';
soglia_diff = 0.8;
area = 1;
dec_centroid = 0;
video = 1;
power_consideration = 0;

store___T = false;
store__DT = false;
storeEvnT = false;
reference = 0;
Use_Frame = 10;
ref_before = 1; %go back 1 frame before the start of the event in order to perform difference with a reference frame
event_index = 1;

%varagin
for k = 1:2:num
    if prod(varargin{k}=='smoothing')
        smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
    
    elseif prod(varargin{k}=='makeVideo')
        video = varargin{k+1}; % 1 = video

    elseif prod(varargin{k}=='dCentroid')
        dec_centroid = varargin{k+1}; % 1 = trova i centri di massa dei frame con evento

    elseif prod(varargin{k}=='detecArea')
        area = varargin{k+1}; % 1 = fai l'analisi delle aree
    
    elseif prod(varargin{k}=='AreaMetho')
        method_area = varargin{k+1};

    elseif prod(varargin{k}=='ThreshRGS')
        soglia_diff = varargin{k+1};

    elseif prod(varargin{k}=='store___T')
        store___T = varargin{k+1};

    elseif prod(varargin{k}=='store__DT')
        store__DT = varargin{k+1};

    elseif prod(varargin{k}=='storeEvnT')
        storeEvnT = varargin{k+1};

    elseif prod(varargin{k}=='rfrcFrame')
        reference = varargin{k+1};

    elseif prod(varargin{k}=='Use_Frame')
        Use_Frame = varargin{k+1};
    end
end

%Cartella per salvataggio dati
sub_folder = ['fStart', num2str(frame_start), '_fdiff_', num2str(fr_diff), '_Nframes_', num2str(Nframes) ,'\'];

 if prod(method_area == 'BiW')

    check = exist(['ThermoResults\',filename,'\BW\', sub_folder]);
    if check ~= 7
        mkdir(['ThermoResults\',filename,'\BW\', sub_folder]);
    end
    
    path = [pwd,'\ThermoResults\',filename,'\BW\',sub_folder];

 elseif prod(method_area == 'RGS')

    check = exist(['ThermoResults\',filename, '\RGS\', sub_folder]);
    if check ~= 7
        mkdir(['ThermoResults\',filename,'\RGS\', sub_folder]);
    end
    
    path = [pwd,'\ThermoResults\',filename,'\RGS\', sub_folder];

elseif prod(method_area == 'CWT')

    check = exist(['ThermoResults\',filename, '\CWT\', sub_folder],'dir');
    if check ~= 7
        mkdir(['ThermoResults\',filename,'\CWT\', sub_folder]);
    end
    
    path = [pwd,'\ThermoResults\',filename,'\CWT\', sub_folder];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inizializzo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%scelta parametri DWT
wname = 'db4';
level =1;

%array per salvare i dati
%(coord, value)
framestates = zeros(Nframes-fr_diff+1,6);
max_temp = zeros(Nframes-fr_diff+1,3); %max_coord, max_value, state_max
arr_aree = zeros(Nframes-fr_diff+1,2);


%variabili per video
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

%variabili per CM
if dec_centroid == 1
    CM = zeros(Nframes-fr_diff+1,2);
end

n_evento_old = 0;

%Salvataggio dei primi dati
m1 = get_data002(filename, frame_start, coordname);
[Rows,Columns] = size(m1);

%reference frame
m_ref = zeros(Rows, Columns);

m_memory = zeros(Rows,Columns,fr_diff);
m_memory(:,:,1) = m1;
m_ref = m1;

%%%%%%%%%%%%%%%% storage %%%%%%%%%%%%%%%%%
if store___T == true %all T
    mtotalT = zeros(Rows,Columns,Nframes);
    mtotalT(:,:,1) = m1; %STORAGE
    m_TmeanStd = zeros(Rows,Columns,2);
    m_TmeanStd(:,:,1) = m1;
    m_TmeanStd(:,:,2) = m1.^2;
end

if store__DT == true
    mtotalDT = zeros(Rows,Columns,Nframes-fr_diff+1);
    m_DTmeanStd = zeros(Rows,Columns,2);
end

if storeEvnT == true
    mtotalEvT = zeros(Rows,Columns,Nframes);
    m_EvenTmeanStd = zeros(Rows,Columns,2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:fr_diff-2
    m_memory(:,:,i+1) = get_data002(filename, frame_start+i, coordname);
    if store___T == true
        mtotalT(:,:,i) = m_memory(:,:,i+1); %STORAGE
        m_TmeanStd(:,:,1) = m_TmeanStd(:,:,1) + m_memory(:,:,i+1);
        m_TmeanStd(:,:,2) = m_TmeanStd(:,:,2) + m_memory(:,:,i+1).^2;
    end %gli altri due casi qui non posso ancora aggiornarli
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DETECTION E ANALISI DATI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_evento = 0;
state_max = 0;
state_min = 0;
m_disp = get_data002(filename, frame_start + fr_diff , coordname) - m_memory(:,:,1);

for i = 0 : Nframes - fr_diff
    %stringa per salvataggio dati
    fname = ['frame', num2str(frame_start+ i + fr_diff)];

    %calcolo tempo
    t = (frame_start + fr_diff + i)/30; %%campionamento a 30 Hz
    framestates(i+1, 6) = t;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %salvataggio dati
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %disp(i);
    %update data
    m_memory(:,:,end) = get_data002(filename, frame_start + i + fr_diff , coordname);
    mdiff = m_memory(:,:,end)-m_memory(:,:,1);
    m_memory(:,:,1:end-1) = m_memory(:,:,2:end);

    %controllo dei dati
    for j = 1 : Rows*Columns
        if isnan(mdiff(j))
            disp(fname)
            m2 = m_memory(:,:,end);
            m1 = m_memory(:,:,1);
            save('m2.mat', 'm2')
            save('m1.mat', 'm1')
            disp(mdiff)
            break
        end
    end

    %decomposizione
    [C, S] = wavedec2(mdiff, level, wname);
    
    %ricostruzione immagine
    imrec = wrcoef2("a",C,S,wname,level);
    %coeff_DWT.(fname) = {C, S};

    %trova temperature massima e minima
    [massimi,~] = hotspot_4(m_memory(:,:,end), 0, 0);
    max_temp(i+1, 1) = massimi(1,1);
    max_temp(i+1, 2) = massimi(1,2);

    if prod(method == 'ThreshNN')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %array massimi e minimi %% lo smoothing lo toglierei
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [max_hotspot, min_hotspot] = hotspot_4(imrec, soglia_max, soglia_min, 'smoothing', smooth);
        Peaks.(fname) = struct('Max', {max_hotspot}, 'Min', {min_hotspot});
        
        %max_hotspot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Controllo primi vicini assoluti
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MASSIMO ASSOLUTO
        %controllo se ci sono dati o è vuota
        if isempty(max_hotspot) == 0
            %seleziono massimo assoluto
            p_max = sortrows(max_hotspot, 2, 'descend');
            framestates(i+1, 1) = p_max(1,1);
            framestates(i+1, 2) = p_max(1,2);
            
            %primi vicini
            point_state_max = primi_vicini(p_max(1,:), 1, imrec);
            max_temp(i+1, 3) = raggruppo_2eventi(max_temp(i+1, 1), max_temp(i+1, 2), framestates(i+1, 1), framestates(i+1, 2), Rows, Columns);

        else   
            framestates(i+1, 1) = 0;
            framestates(i+1, 2) = 0;
            point_state_max = 0;
            max_temp(i+1, 3) = 0;
        end
        
        %MINIMO ASSOLUTO
        %controllo se ci sono dati o è vuota
        if isempty(min_hotspot) == 0
            %seleziono minimo assoluto
            p_min = sortrows(min_hotspot, 2, 'ascend');
            framestates(i+1, 3) = p_min(1,1);
            framestates(i+1, 4) = p_min(1,2);
            
            %primi vicini
            point_state_min = primi_vicini(p_min(1,:), 0,  imrec);
           
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

    else
        disp('Incorrect detection method.');
    end  

    %%%%%%%%%%%%%%%%%%% spostato da DD %%%%%%%%%%%%%%%%%%%%%%
    if i > 0 %cafone, per saltare il primo giro

        %se c'è un evento
        state_max = raggruppo_2eventi(framestates(i,1), framestates(i,2), framestates(i+1,1), framestates(i+1,2), Rows, Columns);
        state_min = raggruppo_2eventi(framestates(i,3), framestates(i,4), framestates(i+1,3), framestates(i+1,4), Rows, Columns);
    
        if framestates(i+1,5) == 1 && framestates(i,5) ~= 0 %potrebbe essere un evento vecchio
            if state_max == 1 || state_min == 1 %l'evento è lo stesso, non incremento l'indicatore
                framestates(i+1,5) = n_evento;
            end
    
            if state_max == 0 && state_min == 0 %nuovo evento
                n_evento = n_evento + 1;
                event_index = i;
                framestates(i+1,5) = n_evento;
                if storeEvnT == true
                    mtotalEvT(:,:,n_evento) = mdiff;
                end
            end
    
        elseif framestates(i+1,5) == 1 && framestates(i,5) == 0 %nuovo evento
            n_evento = n_evento + 1;
            event_index = i;
            framestates(i+1,5) = n_evento;
            if storeEvnT == true
                mtotalEvT(:,:,n_evento) = mdiff;
            end
        end        

        if reference == 1 %different references for each event 
            if n_evento > n_evento_old
                m_ref = get_data002(filename, event_index - ref_before, coordname);
                n_evento_old = n_evento;
            end
            m_disp = m_memory(:,:,end) - m_ref;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%% storage %%%%%%%%%%%%%%%%%
    if store___T == true %all T
        mtotalT(:,:,i + fr_diff) = m_memory(:,:,end);
        m_TmeanStd(:,:,1) = m_TmeanStd(:,:,1) + m_memory(:,:,end);
        m_TmeanStd(:,:,2) = m_TmeanStd(:,:,2) + m_memory(:,:,end).^2;
    end
    
    if store__DT == true 
        mtotalDT(:,:,i + fr_diff) = mdiff;
        m_DTmeanStd(:,:,1) = m_DTmeanStd(:,:,1) + mdiff;
        m_DTmeanStd(:,:,2) = m_DTmeanStd(:,:,2) + mdiff.^2;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Calcolo area senza video
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if area == 1  
        if framestates(i+1, 5) ~= 0
            if prod(method_area == 'BiW') | prod(method_area == 'RGS')
                [area_max, area_min, imsov] = calculate_area_002(imrec, framestates(i+1,:), method_area, soglia_diff);
                Area.(fname) = struct ('Max', area_max, 'Min', area_min);
                arr_aree(i+1,:) = [area_max(1,1), area_min(1,1)]; 

            elseif prod(method_area == 'CWT')
                %punto di massimo per ogni scala e lo salvo
                scala_max = 20;
                max_ampiezze_coeff = zeros(scala_max, 3);
                
                %coefficienti a vari fattori di scala e salvo l'array delle
                %massime ampiezze
                for j=1:scala_max
                    cwtstruct = cwtft2(imrec,'wavelet','mexh','scales',1:1:scala_max);
                    ampiezze_coef = abs(cwtstruct.cfs(:,:,1,j,1)).^2;

                    max_array_coord = find(imregionalmax(ampiezze_coef));
                    max_array = [max_array_coord, ampiezze_coef(max_array_coord)];

                    massimo = sortrows(max_array, 2, 'descend');

                    max_ampiezze_coeff(j, :) = [massimo(1,1), massimo(1,2), j];                          
                end
                
                %trovo il fattore di scala per cui ho le ampiezze massime e
                %salvo
                massimo = sortrows(max_ampiezze_coeff, 2, 'descend');
                fattore_scala = massimo(1,3);
                imsov = abs(cwtstruct.cfs(:,:,1,fattore_scala,1)).^2;
                Area.(fname) = struct ('fattore_scala', fattore_scala);
                arr_aree(i+1,1) = fattore_scala; 
            end

        elseif framestates(i+1, 5) == 0
            if prod(method_area == 'BiW') | prod(method_area == 'RGS')
                Area.(fname) = struct ('Max', 0, 'Min', 0);

            elseif prod(method_area == 'CWT')
                Area.(fname) = struct ('fattore_scala', 0);
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Video con mappa a colori 2d e stampa dei punti in cui ho un evento
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if video == 1
        set(gcf, 'Color','white');
    
        T_max_aus = zeros(Rows,1);
        
        subplot(1,2,1)
        hold on

            if reference == 1
                for k = 1:Rows
                    [T_max_aus(k), ~] = max(abs(m_disp(k,:)));
                end

                [T_max,~] = max(T_max_aus);
                zMin = -T_max;
                zMax = T_max;       

                imagesc(m_disp); %per ora non ricostruita
                title('Temperature difference (ref) [°C]');
            else
                for k = 1:Rows
                    [T_max_aus(k), ~] = max(abs(imrec(k,:)));
                end

                [T_max,~] = max(T_max_aus);
                zMin = -T_max;
                zMax = T_max;    
                imagesc(imrec);
                title('Temperature difference [°C]');
            end

            set(subplot(1,2,1), 'YDir', 'normal')
            clim(subplot(1,2,1), [zMin zMax]);
            colormap(subplot(1,2,1), cm);
            colorbar (subplot(1,2,1));
    
            xlabel('[n° pixel]');
            ylabel('[n° pixel]');
            %title('Temperature difference [°C]');
    
            tempo = append(num2str(framestates(i+1, 6)), ' s');
            annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');
    
            %se state del frame è 1 disegno punto di massimo e/o minimo            
            if framestates(i+1, 5) ~= 0
                evento = append('EVENTO');
                annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', evento, 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');
    
                [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    
                if framestates(i+1, 2) ~= 0 %%se c'è un massimo allora plotta il punto
                    plot(data_x(framestates(i+1,1)), data_y(framestates(i+1,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black') 
                end
    
                if framestates(i+1, 4) ~= 0
                    plot(data_x(framestates(i+1,3)), data_y(framestates(i+1,3)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black')  
                end
                
                hold off
                
                %diesgno area
                if area == 1
                    subplot(1,2,2)
                    hold on
                        imagesc(imsov);
                        colormap(subplot(1,2,2), 'gray');
                        colorbar(subplot(1,2,2));
            
                        xlabel('[n° pixel]');
                        ylabel('[n° pixel]');
                        title('Area event detection');
                        
                        if prod(method_area == 'BiW') | prod(method_area == 'RGS')
                            if Area.(fname).Max(1,1) ~= 0
                                for k = 1 : size(Peaks.(fname).Max)
                                    plot(data_x(Peaks.(fname).Max(k,1)), data_y(Peaks.(fname).Max(k,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
                                end
                            end
            
                            if Area.(fname).Min(1,1) ~= 0
                                for k = 1 : size(Peaks.(fname).Min)
                                    plot(data_x(Peaks.(fname).Min(k,1)), data_y(Peaks.(fname).Min(k,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
                                end
                            end
                        end
                    hold off
                end

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

%chiusura variabili video
if video == 1
    close(gcf);
    close(vidObj);
end

if (store__DT == true || store___T == true) || storeEvnT == true 
    check = exist('termoFiles_mat','dir');
    if check ~= 7
        mkdir termoFiles_mat;
    end
    
    cd termoFiles_mat
    if store___T == true
        mtotalT = delete_zeros(mtotalT);
        save('mtotalT.mat','mtotalT','-mat')
        m_TmeanStd(:,:,1) = m_TmeanStd(:,:,1)/Nframes;
        m_TmeanStd(:,:,2) = sqrt(m_TmeanStd(:,:,2)/Nframes);
        m_TmeanStd = delete_zeros(m_TmeanStd);
        save('m_TmeanStd.mat','m_TmeanStd','-mat')
    end
    if store__DT == true
        %mtotalDT = delete_zeros(mtotalDT);
        save('mtotalDT.mat','mtotalDT','-mat')
        m_DTmeanStd(:,:,1) = m_DTmeanStd(:,:,1)/(Nframes-fr_diff);
        m_DTmeanStd(:,:,2) = sqrt(m_DTmeanStd(:,:,2)/(Nframes-fr_diff));
        m_DTmeanStd = delete_zeros(m_DTmeanStd);
        save('m_DTmeanStd.mat','m_DTmeanStd','-mat')
    end
    if storeEvnT == true    
        %remove extra columns (all zeros)
        idx=[];
        for k=1:size(mtotalEvT,3)
            if all(mtotalEvT(:,:,k)==0,'all')
                idx=[idx,k];
            end
        end
        mtotalEvT(:,:,idx)=[];
        mtotalEvT = delete_zeros(mtotalEvT);
        save('mtotalEvT.mat','mtotalEvT','-mat')
        m_EvenTmeanStd(:,:,1) = m_EvenTmeanStd(:,:,1)/n_evento;
        m_EvenTmeanStd(:,:,2) = sqrt(m_EvenTmeanStd(:,:,2)/n_evento);
        m_EvenTmeanStd = delete_zeros(m_EvenTmeanStd);
        save('m_EvenTmeanStd.mat','m_EvenTmeanStd','-mat')
    end

    cd ..
end


%salva dati
%temperature
save('temperature.mat', 'max_temp');

%area
if area == 1
    save('area.mat', 'Area');
end

%potenza
if power_consideration == 1
    save('power_results.mat', 'power_results');
end

%centro di massa con grafico
if dec_centroid == 1
    save('CM.mat', 'CM');

    %figura con mappatura CM
    figure
    hold on
        title('Position of CM');
        xlabel('[n° pixel]');
        xlim([0 Rows]);
        ylim([0 Columns]);
        ylabel('[n° pixel]');
        A = zeros(Nframes-fr_diff+1, 2);

        for i = 1 : length(CM(:,1))
            if CM(i,1) ~= 0 && CM(i,2) ~= 0
                A(i,:) = [CM(i,1), CM(i,2)];
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

    name = [filename, '_Elect_Thermal_',method_area,'_startFrame',num2str(frame_start),'.mat'];    
    
    results = [framestates(:,6),framestates(:,1),framestates(:,3),framestates(:,2),framestates(:,4), arr_aree(:,1), arr_aree(:,2), framestates(:,5)];
    
    clear S;
end


