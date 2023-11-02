function [frames_states,framestates_arr] = analisi_Nframes001(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, method, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-11-02
%Author: Cristina Zuccali
%analisi_Nframes(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%
%It makes an analys of absolute maxima and minima (selected with a
%threshold) on a group of frames and shows a video
%
%   'filename' = principal part of the file name of frame (without number of frame and .CSV)
%   'Nframes' = number of frames to analyze
%   'frame_start' = number of start frame
%   'fr_diff' = difference beetwen frame to show the difference of temperature
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
%       for video production
%               ('makeVideo', 1) --> makes the video
%
%   'frames_states' = is struct --> {[max_coordinate, max_value], [min_coordinate, min_value], state, time, }
%               where the state is equal to 1 if there is a maximum or/and
%               a minimum, it is 0 if there aren't a maximum and a minimum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    num = length(varargin);

    smooth = 0; %default

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
        
        elseif prod(varargin{k}=='makeVideo')
            video = varargin{k+1}; % 1 = video
        end
    end
 
    %Cartella per salvataggio dati
    check = exist(['ThermoResults\',filename]);
    if check ~= 7
        mkdir(['ThermoResults\',filename]);
    end

    path = [pwd,'\ThermoResults\',filename,'\',];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendi dati e denoising
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %scelta parametri DWT
        wname = 'db4';
        level =1;
    
    %array per salvare i dati dei frame
        framestates = zeros(Nframes-fr_diff-frame_start,6);

    for i=0:(Nframes-fr_diff)

        %mi servono per convertire le posizioni di massimi e minimi in coordinate (y,x)
        if i == 0
            [Rows, Columns] = size (mdiff); 
        end
    
        %calcolo tempo
        t = (frame_start + fr_diff + i)/30; %%campionamento a 30 Hz
        framestates(i+1, 6) = t;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %salvataggio dati
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [m1, mdiff] = get_data(filename, frame_start+i, fr_diff, coordname);


        %decomposizione
            [C, S] = wavedec2(mdiff, level, wname);
        
        %ricostruzione immagine
            imrec = wrcoef2("a",C,S,wname,level);

        %salvataggio dati
            fname = ['frame', num2str(frame_start+i)];
            D.(fname) = {imrec, m1};
            %coeff.DWT(fname) = {C, S};

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Ho due possibilità: salvo C,S sia per m1 che per mdiff
            %oppure salvo imrec e m1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        if prod(method == 'ThreshNN')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %array massimi e minimi %% lo smoothing lo toglierei
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [max_hotspot, min_hotspot] = hotspot_3(imrec, soglia_max, soglia_min, 'smoothing', smooth);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Controllo primi vicini assoluti
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MASSIMO ASSOLUTO
            %controllo se ci sono dati o è vuota
            if isempty(max_hotspot) == 0 %DD perché questo controllo?

                framestates(i+1, 1) = max_hotspot(1,1);
                framestates(i+1, 2) = max_hotspot(1,2);

                %seleziono massimo assoluto
                p_max = sortrows(max_hotspot, 2, 'descend');
                
                %primi vicini
                [point_state_max] = primi_vicini(p_max(1,:), 1, imrec);

            else   
                framestates(i+1, 1) = 0;
                framestates(i+1, 2) = 0;
                point_state_max = 0;
            end
            
            %MINIMO ASSOLUTO
            %controllo se ci sono dati o è vuota
            if isempty(min_hotspot) == 0

                framestates(i+1, 3) = min_hotspot(1,1);
                framestates(i+1, 4) = min_hotspot(1,2);

                %seleziono minimo assoluto
                p_min = sortrows(min_hotspot, 2, 'ascend');
                
                %primi vicini
                [point_state_min] = primi_vicini(p_min(1,:), 0,  imrec);
                
            else
                framestates(i+1, 3) = 0;
                framestates(i+1, 4) = 0;
                point_state_min = 0;
            end
            
            if point_state_max == 1 || point_state_min == 1 
                framestates(i+1, 5) = 1;
                
            else
                framestates(i+1,5) = 0;
                
            end

        else
            disp('Incorrect detection method.');
        end
    end
            
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Raggruppamento frames che detectano lo stesso evento
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %variabile per contare gli eventi e raggrupparli
        n_evento = 0;
        state_max = 0;
        state_min = 0;
    
        for i=1:(Nframes-fr_diff)

            %se c'è un evento
            state_max = raggruppo_2eventi(framestates(i-1,1), framestates(i-1,2), framestates(i,1), framestates(i,2), Rows, Columns);
            state_min = raggruppo_2eventi(framestates(i-1,3), framestates(i-1,4), framestates(i,3), framestates(i,4), Rows, Columns);

            if framestates(i,5) == 1 && framestates(i-1,5) ~= 0
                if state_max == 1 || state_min == 1
                    framestates(i,5) = n_evento;
                end

                if state_max == 0 && state_min == 0
                    n_evento = n_evento + 1;
                    framestates(i,5) = n_evento;
                end

            elseif framestates(i,5) == 1 && framestates(i-1,5) == 0
                n_evento = n_evento + 1;
                framestates(i,5) = n_evento;
            end
            
            state_max = 0;
            state_min = 0;
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Video con mappa a colori 2d e stampa dei punti in cui ho un evento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rallenty = 15;
    frames = zeros(0,6);

    %# create AVI object
    if video == 1
        video_name = [filename,'DETECT_fStart', num2str(frame_start), '_fdiff_', num2str(fr_diff), '_Nframes_', num2str(Nframes) ,'_'];
        video_name = strcat(video_name,'color.avi');

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

        for i=0:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            set(gcf, 'Color','white')

            T_max_aus = zeros(Rows,1);

            for k = 1:Rows
                [T_max_aus(k),k] = max(abs(D.(fname){1}(k,:)));
            end

            [T_max,ind_col] = max(T_max_aus);
            zMin = -T_max;
            zMax = T_max;

            hold on
                imagesc(D.(fname){1});
                clim([zMin, zMax]);
                colormap(cm);
                colorbar;

                xlabel('[n° pixel]');
                ylabel('[n° pixel]');
                zlabel('Temperature difference [°C]');
                title('Temperature difference [°C]');

                tempo = append(num2str(framestates(i, 6)), ' s');
                annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');

                %se state del frame è 1 disegno punto di massimo e/o minimo            
                if framestates(i, 5) ~= 0

                    annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', 'EVENTO', 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');


                    if framestates(i, 2) ~= 0 %%se c'è un massimo allora plotta il punto
                        y = ceil(framestates(i, 1)/Rows); %%floor up
                        x = framestates(i, 1)/Rows) - Rows*(y-1);
                        plot(x, y, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black') 
                    end

                    if framestates(i, 4) ~= 0
                        y = ceil(framestates(i, 3)/Rows); %%floor up
                        x = framestates(i, 3)/Rows) - Rows*(y-1);
                        plot(x, y, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black')  
                    end
                end

            %salvo il frame
            frame = getframe(gcf);
            writeVideo(vidObj, frame);
            delete(findall(gcf,'type','annotation'));
            hold off
            
            clf(gcf);
        end
           
        save('frames.mat', 'framestates');
        close(gcf);
        close(vidObj);

    end

    name = [filename, '_Elect_Thermal_',method,'_startFrame',num2str(frame_start),'.mat'];        
    save(name', 'frames');
end

