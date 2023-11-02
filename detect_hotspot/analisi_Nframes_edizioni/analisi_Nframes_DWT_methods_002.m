function [frames_states] = analisi_Nframes_DWT_methods_002(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-2 Last modification: 2023-11-2
%Author: Cristina Zuccali
%analisi_Nframes_DWT_binary_2(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%
%It makes an analys of absolute maxima and minima (selected with a
%threshold) on a group of frames and shows a video and does the DWT
%
%   'filename' = principal part of the file name of frame (without number of frame and .CSV)
%   'Nframes' = number of frames to analyze
%   'frame_start' = number of start frame
%   'fr_diff' = difference beetwen frame to show the difference of temperature
%   'coordname' = name of file with coordinates of the wanted region
%   'soglia_max' = threshold for the selection of maxima
%   'soglia_min' = threshold for the selection of minima
%
%   'varargin' : 
%
%       there is the possibility of smooth mdiff data
%               ('smoothing', 1) --> smoothing of mdiff data
%               ('smoothing', 0) --> mdiff is left invariate

%       for video production
%               ('makeVideo', 1) --> makes the video
%       
%       to choose the method for the spot characterization
%               ('AreaMetho', 'BiW') = binarization 
%               ('AreaMetho', 'RGS') = regional growth method
%               ('ThreshRGS', ...) for pixels selection in regional growth segmentation
%
%   'frames_states' = is a struct --> {[max_coordinate, max_value], [min_coordinate, min_value], state, time}
%               where the state is equal to 1 if there is a maximum or/and
%               a minimum, it is 0 if there aren't a maximum and a minimum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    num = length(varargin);
    method = 1; %default

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
        
        elseif prod(varargin{k}=='makeVideo')
            video = varargin{k+1}; % 1 = video
        
        elseif prod(varargin{k}=='AreaMetho')
            method = varargin{k+1};

        elseif prod(varargin{k}=='ThreshRGS')
            soglia_diff = varargin{k+1};
        end
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Cartella per salvataggio dati
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if method == 1
        check = exist(['ThermoResults\BW\',filename]);
        if check ~= 7
            mkdir(['ThermoResults\BW\',filename]);
        end
        
        path = [pwd,'\ThermoResults\BW\',filename,'\',];
    
    elseif method == 2
        check = exist(['ThermoResults\RGS\',filename]);
        if check ~= 7
            mkdir(['ThermoResults\RGS\',filename]);
        end
        
        path = [pwd,'\ThermoResults\RGS\',filename,'\',];
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %prendi dati
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %attenzione: è importante fare clear o eliminare la struct D
        for i=0:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            [m1, mdiff] = get_data(filename, frame_start+i, fr_diff, coordname);
            D.(fname) = {mdiff};

            if i == 0
                [Rows, Columns] = size (mdiff); %mi servono per convertire le posizioni di massimi e minimi in coordinate (y,x)
            end
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %array massimi e minimi
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %attenzione: è importante fare clear o eliminare la struct P
        for i=0:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            [max_hotspot, min_hotspot, z] = hotspot_3(D.(fname){1}, soglia_max, soglia_min, 'smoothing', smooth);
            P.(fname) = {max_hotspot, min_hotspot, z}; 
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Controllo primi vicini assoluti
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=0:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            
            %MASSIMO ASSOLUTO
            %controllo se ci sono dati o è vuota
            if isempty(P.(fname){1,1}) == 0
                %seleziono massimo assoluto
                p_max = sortrows(P.(fname){1,1}, 2, 'descend');
                
                %Costruisco S_max
                [peak, point_state_max] = primi_vicini(p_max(1,:), 1, P.(fname){3});
                S_max.(fname) = {peak, point_state_max};
                
            else
                S_max.(fname) = {[000, 000], 0};
            end
            
            %MINIMO ASSOLUTO
            %controllo se ci sono dati o è vuota
            if isempty(P.(fname){1,2}) == 0
                %seleziono minimo assoluto
                p_min = sortrows(P.(fname){1,2}, 2, 'ascend');
                
                %Costruisco S_min
                [peak, point_state_min] = primi_vicini(p_min(1,:), 0,  P.(fname){3});
                S_min.(fname) = {peak, point_state_min};
                
            else
                S_min.(fname) = {[000, 000] , 0};
            end
            
            state_tot = S_max.(fname){1,2} + S_min.(fname){1,2};
            t = (frame_start + fr_diff + i)/30; %%campionamento a 30 Hz
            
            if state_tot == 0
                frames_states.(fname) = {S_max.(fname)(1,1), S_min.(fname)(1,1), 0, t};
                
            else
                frames_states.(fname) = {S_max.(fname)(1,1), S_min.(fname)(1,1), 1, t};
                
            end
        end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Raggruppamento frames che detectano lo stesso evento
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %variabile per contare gli eventi e raggrupparli
        n_evento = 0;
        state_max = 0;
        state_min = 0;

        mat_n_evento = zeros(Nframes-fr_diff, 1);
    
        for i=1:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            fname_prec = ['frame', num2str((frame_start+i)-1)];
            
            %se c'è un evento
           state_max = raggruppo_2eventi(frames_states.(fname_prec){1,1}{1,1}, frames_states.(fname){1,1}{1,1}, Rows, Columns);
           state_min = raggruppo_2eventi(frames_states.(fname_prec){1,2}{1,1}, frames_states.(fname){1,2}{1,1}, Rows, Columns);


            if frames_states.(fname){3} == 1 && frames_states.(fname_prec){3} ~= 0
                if state_max == 1 || state_min == 1
                    frames_states.(fname){1,3} = n_evento;
                end

                if state_max == 0 && state_min == 0
                    n_evento = n_evento + 1;
                    frames_states.(fname){1,3} = n_evento;
                end

            elseif frames_states.(fname){3} == 1 && frames_states.(fname_prec){3} == 0
                n_evento = n_evento + 1;
                frames_states.(fname){1,3} = n_evento;
            end
            
            mat_n_evento(i+1) = n_evento;
            state_max = 0;
            state_min = 0;
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Video con mappa a colori 2d e stampa dei punti in cui ho un evento
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rallenty = 20;
        frames = zeros(0,8);
    
        %# create AVI object
        if video == 1
            video_name = [filename,'DETECT_fStart', num2str(frame_start), '_fdiff_', num2str(fr_diff), '_Nframes_', num2str(Nframes) ,'_DWT_BW'];

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
            set(gcf, 'Color','white')
    
            load('ThermoColorMap1.mat');
    
            for i=0:(Nframes-fr_diff)
                fname = ['frame', num2str(frame_start+i)];
                area_max = 0;
                area_min = 0;
    
                T_max_aus = zeros(size((P.(fname){1,3}),2),1);
                ind_row = zeros(size(P.(fname){1,3},2),1);
                [Rows, Columns] = size (P.(fname){1,3});
                for k = 1:size(P.(fname){1,3},2)
                    [T_max_aus(k),ind_row(k)] = max(abs(P.(fname){1,3}(k,:)));
                end
    
                [T_max,ind_col] = max(T_max_aus);
                zMin = -T_max;
                zMax = T_max;
    
                if frames_states.(fname){1,3} ~= 0
                    subplot(2,3,1);
                    hold on
                        imagesc(P.(fname){1,3});
                        clim([zMin, zMax]);
                        colormap(subplot(2,3,1), cm);
                        colorbar(subplot(2,3,1));
            
                        xlabel('[n° pixel]');
                        ylabel('[n° pixel]');
                        zlabel('Temperature difference [°C]');
                        title('Temperature difference [°C]');
                        tempo = append(num2str(frames_states.(fname){1,4}), ' s');
                        annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');
            
                        %se state dc'è un evento disegno punto di massimo e/o minimo 
                        evento = append('EVENTO ', num2str(frames_states.(fname){3}));
                        annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', evento, 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');
                        [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
                        if isempty(P.(fname){1,1}) == 0
                            plot(data_x(frames_states.(fname){1,1}{1,1}(1,1)),data_y(frames_states.(fname){1,1}{1,1}(1,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black'); 
                        end
        
                        if isempty(P.( fname){1,2}) == 0
                            plot(data_x(frames_states.(fname){1,2}{1,1}(1,1)),data_y(frames_states.(fname){1,2}{1,1}(1,1)), 'o', 'MarkerSize', 8,'MarkerFaceColor', 'black'); 
                        end
                    hold off
    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Analisi DWT e calcolo area
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                %scelta parametri DWT
                    wname = 'db4';
                    level =1;

                %decomposizione
                    [C, S] = wavedec2(P.(fname){1,3}, level, wname);
                
                %ricostruzione immagine
                    imrec = wrcoef2("a",C,S,wname,level);

                %soglia e selezione dati 
                    % [thr,sorh,keepapp] = ddencmp('den', 'wv', imrec);
                    % imden = wdencmp('gbl',imrec,wname,level,thr,'h',keepapp);
              
                %se c'è sia un massimo che un minimo stampo l'immagine
                    controllo_stato = 0;
                    
                %se c'è un massimo lascio la matrice come è
                    if isempty(P.(fname){1,1}) == 0
    
                        controllo_stato = controllo_stato + 1;
                        
                        %scelta del metodo
                        
                        if method == 1
                            BW = imbinarize(imrec, "global");
        
                            seD = strel('diamond', 1);
                            BWfinal = imerode(BW, seD);
                            BWfinal = imerode(BWfinal, seD);
        
                            subplot(2,3,2)
                            imagesc(BWfinal)
                            set(subplot(2,3,2), 'YDir', 'normal')
                            colormap(subplot(2,3,2),'gray')
                            colorbar(subplot(2,3,2));
                            title('Segmented image of hot regions');
        
                            imsov_max=labeloverlay(P.(fname){1,3},BWfinal);
        
                            subplot(2,3,3)
                            imagesc(imsov_max)
                            set(subplot(2,3,3), 'YDir', 'normal')
                            colormap(subplot(2,3,3),'gray')
                            colorbar(subplot(2,3,3));
                            title('Confronto delle regioni calde');
                            
                            %calcolo l'area
                            area_max = bwarea(BWfinal);
                            str = append('A(max) = ', num2str(area_max));
                            annotation('textbox', 'Position', [0.9 0.80 0.1 0.1], 'String', str, 'FitBoxToText', true, 'EdgeColor', 'g', 'BackgroundColor', 'g');
                        end

                        if method == 2
                            RS = regional_growth_segmentation_2(frames_states.(fname){1,1}{1,1}, 1, imrec, soglia_diff);

                            subplot(2,3,2)
                            hold on
                            imagesc(RS)
                            set(subplot(2,3,2), 'YDir', 'normal')
                            colormap(subplot(2,3,2),'gray')
                            colorbar(subplot(2,3,2));
                            title('Method: regional growth segmentation, hot regions');
                            plot(data_x(frames_states.(fname){1,1}{1,1}(1,1)),data_y(frames_states.(fname){1,1}{1,1}(1,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'red'); 
                            hold off

                            imsov_max=labeloverlay(P.(fname){1,3},RS);
        
                            subplot(2,3,3)
                            imagesc(imsov_max)
                            set(subplot(2,3,3), 'YDir', 'normal')
                            colormap(subplot(2,3,3),'gray')
                            colorbar(subplot(2,3,3));
                            title('Confronto delle regioni calde');
                            
                            %calcolo l'area
                            area_max = bwarea(RS);
                            str = append('A(max) = ', num2str(area_max));
                            annotation('textbox', 'Position', [0.9 0.80 0.1 0.1], 'String', str, 'FitBoxToText', true, 'EdgeColor', 'g', 'BackgroundColor', 'g');
                        end
                    end

                %se c'è un minimo inverto il segno della matrice così da
                %poterlo vedere come bianco nell'immagine binaria
                    if isempty(P.(fname){1,2}) == 0
                        controllo_stato = controllo_stato + 1;
                        
                        %scelta del metodo
                        
                        if method == 1 
                            imrec_inv = -imrec;
    
                            BW = imbinarize(imrec_inv, "global");
        
                            seD = strel('diamond', 1);
                            BWfinal = imerode(BW, seD);
                            BWfinal = imerode(BW, seD);
        
                            subplot(2,3,4)
                            imagesc(BWfinal)
                            set(subplot(2,3,4), 'YDir', 'normal')
                            colormap(subplot(2,3,4),'gray')
                            colorbar(subplot(2,3,4));
                            title('Segmented image of cold regions');
        
                            imsov_min=labeloverlay(-P.(fname){1,3},BWfinal);
        
                            subplot(2,3,5)
                            imagesc(imsov_min)
                            set(subplot(2,3,5), 'YDir', 'normal')
                            colormap(subplot(2,3,5),'gray')
                            colorbar(subplot(2,3,5));
                            title('Confronto delle regioni fredde');
    
    
                            %calcolo l'area
                            area_min = bwarea(BWfinal);
                            str = append('A(min) = ', num2str(area_min));
                            annotation('textbox', 'Position', [0.9 0.75 0.08 0.1], 'String', str, 'FitBoxToText', true, 'EdgeColor', 'g', 'BackgroundColor', 'g');
                        end

                        if method == 2
                            RS = regional_growth_segmentation_2(frames_states.(fname){1,2}{1,1}, 0, +imrec, soglia_diff);
                            subplot(2,3,4)
                            hold on
                            imagesc(RS)
                            set(subplot(2,3,4), 'YDir', 'normal')
                            colormap(subplot(2,3,4),'gray')
                            colorbar(subplot(2,3,4));
                            title('Method: regional growth segmentation, cold regions');
                            plot(data_x(frames_states.(fname){1,2}{1,1}(1,1)),data_y(frames_states.(fname){1,2}{1,1}(1,1)), 'o', 'MarkerSize', 8,'MarkerFaceColor', 'red'); 
                            hold off

                            imsov_min=labeloverlay(-P.(fname){1,3},RS);
        
                            subplot(2,3,5)
                            imagesc(imsov_min)
                            set(subplot(2,3,5), 'YDir', 'normal')
                            colormap(subplot(2,3,5),'gray')
                            colorbar(subplot(2,3,5));
                            title('Confronto delle regioni fredde');
                            
                            %calcolo l'area
                            area_min = bwarea(RS);
                            str = append('A(min) = ', num2str(area_min));
                            annotation('textbox', 'Position', [0.9 0.75 0.1 0.1], 'String', str, 'FitBoxToText', true, 'EdgeColor', 'g', 'BackgroundColor', 'g');
                        end

                    end

                    %sovrappongo le immagine ottenute
                    if controllo_stato == 2
                        subplot(2,3,6)
                        imsov = imsov_max + imsov_min;
                        imagesc(imsov)
                        set(subplot(2,3,6), 'YDir', 'normal')
                        colormap(subplot(2,3,6),'gray')
                        colorbar(subplot(2,3,6));
                        title('Confronto delle regioni calde e fredde');    % la differenza di temperatura è in valore assoluto
                    end

                else
                    subplot(2,3,1);
                    hold on
                        imagesc(P.(fname){1,3});
                        clim([zMin, zMax]);
                        colormap(subplot(2,3,1),cm);
                        colorbar(subplot(2,3,1));
            
                        xlabel('[n° pixel]');
                        ylabel('[n° pixel]');
                        zlabel('Temperature difference [°C]');
                        title('Temperature difference [°C]');
                        tempo = append(num2str(frames_states.(fname){1,4}), ' s');
                        annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');
                    hold off
                end
        
                %salvo il frame
                frame = getframe(gcf);
                writeVideo(vidObj, frame);
                delete(findall(gcf,'type','annotation'));
                cla(subplot(2,3,1));
                cla(subplot(2,3,2));
                cla(subplot(2,3,3));
                cla(subplot(2,3,4));
                cla(subplot(2,3,5));
                cla(subplot(2,3,6));
        
                frames(end+1,:) = [frames_states.(fname){1,1}{1,1}(1,1) frames_states.(fname){1,1}{1,1}(1,2) frames_states.(fname){1,2}{1,1}(1,1) frames_states.(fname){1,2}{1,1}(1,2) frames_states.(fname){1,3} frames_states.(fname){1,4}, area_max, area_min]; %coord_max, max, coord_min, min, state, tempo, area_max, area_min
            end 
    
        save('frames.mat', 'frames');
        close(gcf);
        close(vidObj);

    end
    detMethod = 'ThresholdNN'; %modifica in base agli inputs
    areaMethod = 'CWT'; %modifica in base agli inputs

    name = [filename, '_Elect_Thermal_',detMethod,'_', areaMethod,'_startFrame',num2str(frame_start),'.mat'];        
    save(name', 'frames');
end

