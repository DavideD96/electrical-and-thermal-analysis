function [frames_states,framestates_arr] = analisi_Nframes(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, method, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-10-16
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
    
    framestates_arr = zeros(Nframes-fr_diff-frame_start,6);

    if prod(method == 'ThreshNN')
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
            if isempty(P.(fname){1,1}) == 0 %DD perché questo controllo?
                %seleziono massimo assoluto
                p_max = sortrows(P.(fname){1,1}, 2, 'descend');
                
                %Costruisco S_max
                [peak, point_state_max] = primi_vicini(p_max(1,:), 1, P.(fname){3}); %DD perchè restituire peak?
                S_max.(fname) = {peak, point_state_max};
                % if i == 2
                %     point_state_max
                % end
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
            


            state_tot = S_max.(fname){1,2} + S_min.(fname){1,2}; %DD + = or?
            t = (frame_start + fr_diff + i)/30; %%campionamento a 30 Hz
            
            if state_tot == 0
                framestates_arr(i+1,:) = [S_max.(fname){1,1}(1),S_max.(fname){1,1}(2), S_min.(fname){1,1}(1),S_min.(fname){1,1}(2), 0, t];
                frames_states.(fname) = {S_max.(fname)(1,1), S_min.(fname)(1,1), 0, t};
                
            else
                framestates_arr(i+1,:) = [S_max.(fname){1,1}(1),S_max.(fname){1,1}(2), S_min.(fname){1,1}(1),S_min.(fname){1,1}(2), 1, t];
                frames_states.(fname) = {S_max.(fname)(1,1), S_min.(fname)(1,1), 1, t};
                
            end
        end
    else
        disp('Incorrect detection method.');
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

        for i=0:(Nframes-fr_diff)
            fname = ['frame', num2str(frame_start+i)];
            set(gcf, 'Color','white')

            load('ThermoColorMap1.mat');

            T_max_aus = zeros(size((P.(fname){1,3}),2),1);
            ind_row = zeros(size(P.(fname){1,3},2),1);
            [Rows, Columns] = size (P.(fname){1,3});
            for k = 1:size(P.(fname){1,3},2)
                [T_max_aus(k),ind_row(k)] = max(abs(P.(fname){1,3}(k,:)));
            end

            [T_max,ind_col] = max(T_max_aus);
            zMin = -T_max;
            zMax = T_max;

            hold on
                imagesc(P.(fname){1,3});
                caxis([zMin, zMax]);
                colormap(cm);
                colorbar;

                xlabel('[n° pixel]');
                ylabel('[n° pixel]');
                zlabel('Temperature difference [°C]');
                title('Temperature difference [°C]');
                tempo = append(num2str(frames_states.(fname){1,4}), ' s');
                annotation('textbox', 'Position', [0.9 0.85 0.1 0.1], 'String', tempo, 'FitBoxToText', true, 'EdgeColor', 'k', 'BackgroundColor', 'w');

                %se state del frame è 1 disegno punto di massimo e/o minimo            
                if frames_states.(fname){1,3} ~= 0
                    annotation('textbox', 'Position', [0.9 0.9 0.1 0.1], 'String', 'EVENTO', 'FitBoxToText', true, 'EdgeColor', 'r', 'BackgroundColor', 'r');
                    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
                    if isempty(P.(fname){1,1}) == 0
                        plot(data_x(frames_states.(fname){1,1}{1,1}(1,1)),data_y(frames_states.(fname){1,1}{1,1}(1,1)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black') 
                    end

                    if isempty(P.(fname){1,2}) == 0
                        plot(data_x(frames_states.(fname){1,2}{1,1}(1,1)),data_y(frames_states.(fname){1,2}{1,1}(1,1)), 'o', 'MarkerSize', 8,'MarkerFaceColor', 'black') 
                    end
                end

            %salvo il frame
            frame = getframe(gcf);
            writeVideo(vidObj, frame);
            delete(findall(gcf,'type','annotation'));
            hold off
            
            clf(gcf);

            frames(end+1,:) = [frames_states.(fname){1,1}{1,1}(1,1) frames_states.(fname){1,1}{1,1}(1,2) frames_states.(fname){1,2}{1,1}(1,1) frames_states.(fname){1,2}{1,1}(1,2) frames_states.(fname){1,3} frames_states.(fname){1,4}]; %coord_max, max, coord_min, min, state, tempo
        end
           
        save('frames.mat', 'frames');
        close(gcf);
        close(vidObj);

    end

    name = [filename, '_Elect_Thermal_',method,'_startFrame',num2str(frame_start),'.mat'];        
    save(name', 'frames');
end

