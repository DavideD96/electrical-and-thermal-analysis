function [frames_states] = analisi_Nframes(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-19 Last modification: 2023-10-20
%Author: Cristina Zuccali
%analisi_Nframes_DWT_binary_2(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%
%It makes an analys of absolute maxima and minima (selected with a
%threshold) on a group of frames and shows a video and does the CWT
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
%       there is the possibility of smooth mdiff data
%               ('smoothing', 1) --> smoothing of mdiff data
%               ('smoothing', 0) --> mdiff is left invariate
%       for video production
%               ('makeVideo', 1) --> makes the video
%
%   'frames_states' = is struct --> {[max_coordinate, max_value], [min_coordinate, min_value], state, time}
%               where the state is equal to 1 if there is a maximum or/and
%               a minimum, it is 0 if there aren't a maximum and a minimum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    num = length(varargin);

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
        
        elseif prod(varargin{k}=='makeVideo')
            video = varargin{k+1}; % 1 = video
        end
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Cartella per salvataggio dati
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check = exist(['ThermoResults\',filename]);
    if check ~= 7
        mkdir(['ThermoResults\',filename]);
    end
    
    path = [pwd,'\ThermoResults\',filename,'\',];
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %prendi dati
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %attenzione: è importante fare clear o eliminare la struct D
        for i=0:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            [m1, mdiff] = get_data(filename, frame_start+i, fr_diff, coordname);
            D.(fname) = {mdiff};
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
        %attenzione: è importante fare clear o eliminare la struct S, S_max,
        %S_min
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
    %Video con mappa a colori 2d e stampa dei punti in cui ho un evento
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rallenty = 20;
        frames = zeros(0,7);
    
        %# create AVI object
        if video == 1
            video_name = [filename,'DETECT_fStart', num2str(frame_start), '_fdiff_', num2str(fr_diff), '_Nframes_', num2str(Nframes) ,'_CWT'];
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
    
                T_max_aus = zeros(size((P.(fname){1,3}),2),1);
                ind_row = zeros(size(P.(fname){1,3},2),1);
                [Rows, Columns] = size (P.(fname){1,3});
                for k = 1:size(P.(fname){1,3},2)
                    [T_max_aus(k),ind_row(k)] = max(abs(P.(fname){1,3}(k,:)));
                end
    
                [T_max,ind_col] = max(T_max_aus);
                zMin = -T_max;
                zMax = T_max;
    
                if frames_states.(fname){1,3} == 1
                    subplot(1,2,1);
                    hold on
                        imagesc(P.(fname){1,3});
                        clim([zMin, zMax]);
                        colormap(subplot(1,2,1), cm);
                        colorbar(subplot(1,2,1));
            
                        xlabel('[n° pixel]');
                        ylabel('[n° pixel]');
                        zlabel('Temperature difference [°C]');
                        title('Temperature difference [°C]');
                        tempo = append(num2str(frames_states.(fname){1,4}), ' s');
                        annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');
            
                        %se state del frame è 1 disegno punto di massimo e/o minimo            
        
                        annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', 'EVENTO', 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');
                        [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
                        if isempty(P.(fname){1,1}) == 0
                            plot(data_x(frames_states.(fname){1,1}{1,1}(1,1)),data_y(frames_states.(fname){1,1}{1,1}(1,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black'); 
                        end
        
                        if isempty(P.(fname){1,2}) == 0
                            plot(data_x(frames_states.(fname){1,2}{1,1}(1,1)),data_y(frames_states.(fname){1,2}{1,1}(1,1)), 'o', 'MarkerSize', 8,'MarkerFaceColor', 'black'); 
                        end
                    hold off
    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Analisi CWT
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                %CWT e ampiezze dei coefficienti a varie scale: prendo il
                %punto di massimo per ogni scala e lo salvo
                    scala_max = 20;
                    max_ampiezze_coeff = zeros(scala_max, 3);
                    
                    %coefficienti a vari fattori di scala e salvo l'array delle
                    %massime ampiezze
                    for i=1:1:scala_max
                        cwtstruct = cwtft2(P.(fname){1,3},'wavelet','mexh','scales',1:1:scala_max);
                        %cwtstruct = cwtft2(P.(fname){1,3},'wavelet','marr','scales',1:1:scala_max, 'angles', 7*pi/8);
                        ampiezze_coef = abs(cwtstruct.cfs(:,:,1,i,1)).^2;
    
                        max_array_coord = find(imregionalmax(ampiezze_coef));
                        max_array = [max_array_coord, ampiezze_coef(max_array_coord)];
    
                        massimo = sortrows(max_array, 2, 'descend');
    
                        max_ampiezze_coeff(i, :) = [massimo(1,1), massimo(1,2), i];                          
                    end
                    
                    %trovo il fattore di scala per cui ho le ampiezze massime e
                    %plotto le ampiezze dei coefficienti
                    massimo = sortrows(max_ampiezze_coeff, 2, 'descend');
                    
                    subplot(1,2,2);
                    hold on
                        fattore_scala = massimo(1,3);
                        ampiezze_coef = abs(cwtstruct.cfs(:,:,1,fattore_scala,1)).^2;
                        imagesc(ampiezze_coef);
                        set(subplot(1,2,2), 'YDir', 'normal')
                        colormap(subplot(1,2,2),'gray')
                        colorbar(subplot(1,2,2));
                        str = append('CWT con a = ', num2str(fattore_scala));
                        title (str);
                    hold off
    
                else
                    subplot(1,2,1);
                    hold on
                        imagesc(P.(fname){1,3});
                        clim([zMin, zMax]);
                        colormap(subplot(1,2,1),cm);
                        colorbar(subplot(1,2,1));
            
                        xlabel('[n° pixel]');
                        ylabel('[n° pixel]');
                        zlabel('Temperature difference [°C]');
                        title('Temperature difference [°C]');
                        tempo = append(num2str(frames_states.(fname){1,4}), ' s');
                        annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');
                    hold off
                    fattore_scala = 0;
                end
        
                %salvo il frame
                frame = getframe(gcf);
                writeVideo(vidObj, frame);
                delete(findall(gcf,'type','annotation'));
                cla(subplot(1,2,1));
                cla(subplot(1,2,2));
        
                frames(end+1,:) = [frames_states.(fname){1,1}{1,1}(1,1) frames_states.(fname){1,1}{1,1}(1,2) frames_states.(fname){1,2}{1,1}(1,1) frames_states.(fname){1,2}{1,1}(1,2) frames_states.(fname){1,3} frames_states.(fname){1,4}, fattore_scala]; %coord_max, max, coord_min, min, state, tempo, fattore_scala
            end 
    
        close(gcf);
        close(vidObj);
    end
    
    save('frames.mat', 'frames');
end

