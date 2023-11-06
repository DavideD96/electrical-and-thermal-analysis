function [framestates, area_arr] = analisi_Nframes003(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, method, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-11-03
%Author: Cristina Zuccali
%analisi_Nframes(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%
%It makes an analys of absolute maxima and minima (selected with a
%threshold) on a group of frames and shows a video
%
% Correction for area calculation (expecially for BiW) and plotting
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
%       for area detection
%               ('detecArea', 1) --> calculate the area
%
%       to choose the method for the spot characterization
%               ('AreaMetho', 'BiW') = binarization 
%               ('AreaMetho', 'RGS') = regional growth method
%               ('ThreshRGS', ...) for pixels selection in regional growth segmentation
%
%   'framestates' = is an array --> [max_coordinate, max_value, min_coordinate, min_value, state, time]
%               where state = 0 means that there is no event in the frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    num = length(varargin);
    
    %PARAMETRI DI DEFAULT
    smooth = 0;
    method_area = 'BiW';
    soglia_diff = 0.8;
    area = 1;

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
        
        elseif prod(varargin{k}=='makeVideo')
            video = varargin{k+1}; % 1 = video

        elseif prod(varargin{k}=='detecArea')
            area = varargin{k+1}; % 1 = fai l'analisi delle aree
        
        elseif prod(varargin{k}=='AreaMetho')
            method_area = varargin{k+1};

        elseif prod(varargin{k}=='ThreshRGS')
            soglia_diff = varargin{k+1};
        end
    end
 
    %Cartella per salvataggio dati
     if prod(method_area == 'BiW')

        check = exist(['ThermoResults\',filename,'\BW\']);
        if check ~= 7
            mkdir(['ThermoResults\',filename,'\BW\',]);
        end
        
        path = [pwd,'\ThermoResults\',filename,'\BW\',];
    
     elseif prod(method_area == 'RGS')

        check = exist(['ThermoResults\',filename, '\RGS\']);
        if check ~= 7
            mkdir(['ThermoResults\',filename,'\RGS\']);
        end
        
        path = [pwd,'\ThermoResults\',filename,'\RGS\',];
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendi dati e denoising
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %scelta parametri DWT
        wname = 'db4';
        level =1;
    
    %array per salvare i dati dei frame
        framestates = zeros(Nframes-fr_diff-frame_start,6);

    for i=0:(Nframes-fr_diff)

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
            D.(fname) = {imrec};
            coeff_DWT.(fname) = {C, S};

        %mi servono per convertire le posizioni di massimi e minimi in coordinate (y,x)
        if i == 0
            [Rows, Columns] = size (mdiff); 
        end
    

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Ho due possibilità: salvo C,S sia per m1 che per mdiff
            %oppure salvo imrec e m1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        if prod(method == 'ThreshNN')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %array massimi e minimi %% lo smoothing lo toglierei
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [max_hotspot, min_hotspot] = hotspot_3(imrec, soglia_max, soglia_min, 'smoothing', smooth);
        Peaks.(fname) = struct('Max', {max_hotspot}, 'Min', {min_hotspot});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Controllo primi vicini assoluti
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %MASSIMO ASSOLUTO
            %controllo se ci sono dati o è vuota
            if isempty(max_hotspot) == 0 %DD perché questo controllo?

                %seleziono massimo assoluto
                p_max = sortrows(max_hotspot, 2, 'descend');
                framestates(i+1, 1) = p_max(1,1);
                framestates(i+1, 2) = p_max(1,2);
                
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

                %seleziono minimo assoluto
                p_min = sortrows(min_hotspot, 2, 'ascend');
                framestates(i+1, 3) = p_min(1,1);
                framestates(i+1, 4) = p_min(1,2);
                
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
    
        for i=2:(Nframes-fr_diff)

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
            
            subplot(1,2,1)
            hold on
                imagesc(D.(fname){1});
                set(subplot(2,3,3), 'YDir', 'normal')
                clim(subplot(1,2,1), [zMin, zMax]);
                colormap(subplot(1,2,1), cm);
                colorbar (subplot(1,2,1));

                xlabel('[n° pixel]');
                ylabel('[n° pixel]');
                title('Temperature difference [°C]');

                tempo = append(num2str(framestates(i+1, 6)), ' s');
                annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');

                %se state del frame è 1 disegno punto di massimo e/o minimo            
                if framestates(i+1, 5) ~= 0
                    evento = append('EVENTO ', num2str(framestates(i+1, 5)));
                    annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', evento, 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');

                    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);

                    if framestates(i+1, 2) ~= 0 %%se c'è un massimo allora plotta il punto
                        plot(data_x(framestates(i+1,1)), data_y(framestates(i+1,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black') 
                    end

                    if framestates(i+1, 4) ~= 0
                        plot(data_x(framestates(i+1,3)), data_y(framestates(i+1,3)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black')  
                    end
                end

                hold off

                %ricostruisco immagine
                %imrec = wrcoef2("a",coeff_DWT.(fname){1},  coeff_DWT.(fname){2},wname,level);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %metodo calcolo area
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if framestates(i+1, 5) ~= 0 && area == 1
                    [area_max, area_min, imsov] = calculate_area_002(D.(fname){1}, framestates(i+1,:), method_area, soglia_diff);
                    Area.(fname) = struct ('Max', area_max, 'Min', area_min);

                    subplot(1,2,2)
                    hold on
                        imagesc(imsov);
                        clim([zMin, zMax]);
                        colormap(subplot(1,2,2), 'gray');
                        colorbar(subplot(1,2,2));

                        xlabel('[n° pixel]');
                        ylabel('[n° pixel]');
                        title('Area event detection');

                        if Area.(fname).Max(1,1) ~= 0
                            for i = 1 : size(Peaks.(fname).Max)
                                plot(data_x(Peaks.(fname).Max(i,1)), data_y(Peaks.(fname).Max(i,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
                            end
                        end

                        if Area.(fname).Min(1,1) ~= 0
                            for i = 1 : size(Peaks.(fname).Min)
                                plot(data_x(Peaks.(fname).Min(i,1)), data_y(Peaks.(fname).Min(i,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
                            end
                        end
                    hold off

                elseif framestates(i+1, 5) == 0 && area == 1
                     Area.(fname) = struct ('Max', 0, 'Min', 0);
                end

            %salvo il frame
            frame = getframe(gcf);
            writeVideo(vidObj, frame);
            delete(findall(gcf,'type','annotation'));
            
            clf(gcf);
        end
           
        save('frames.mat', 'framestates');
        save('area.mat', 'Area');
        close(gcf);
        close(vidObj);

    end

    name = [filename, '_Elect_Thermal_',method_area,'_startFrame',num2str(frame_start),'.mat'];        
end

