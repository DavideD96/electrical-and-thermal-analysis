function [frames_states_array_ripuliti, frames_states_struct_ripuliti] = evento_max_temp_003_multiEvento_001(frames_states_array, frames_states_struct, frame_start, fr_diff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-22 Last modification: 2024-01-22
%Authors: Cristina Zuccali
%evento_max_temp_003_multiEvento_001(frames_states)
%prende il rappresentante di ogni gruppo evento nella versione di
%rilevazione multi-evento
%   'frames_states_array' = is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame
%   'frames_states_struct' = is a struct --> [time [s], {massimi}, {minimi}, area_max, area_min, state]
%
%   torna struct e array ripuliti: eventi a zero tranne quelli
%   rappresentanti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%iniziazlizzo variabili
%variabili di appoggio
peak_array = zeros(length(frames_states_array(:,1)), 4);

%variabili da restituire
frames_states_array_ripuliti = frames_states_array;
frames_states_struct_ripuliti = frames_states_struct;

%prendo massimi e minimi di ogni evento
j = 1;
while j <= length(frames_states_array(:,8))
    n_evento = frames_states_array(j, 8);
    eventi = 0;

    peaks_array_supply = zeros(0, 4); %coord, value, evento, index
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GET EVENTO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1 : length(frames_states_array(:,1))
        if (frames_states_array(i, 8) == n_evento & n_evento ~= 0)
            if frames_states_array(i, 4) >= abs(frames_states_array(i, 5))
                peaks_array_supply(end+1, 1) = frames_states_array(i, 2);   
                peaks_array_supply(end, 2) = frames_states_array(i, 4);
                peaks_array_supply(end, 3) = frames_states_array(i, 8);
                peaks_array_supply(end, 4) = i;

            elseif frames_states_array(i, 4) <= abs(frames_states_array(i, 5))
                peaks_array_supply(end+1, 1) = frames_states_array(i, 3);   
                peaks_array_supply(end, 2) = abs(frames_states_array(i, 5)); %
                peaks_array_supply(end, 3) = frames_states_array(i, 8);
                peaks_array_supply(end, 4) = i;
            end

            eventi = eventi + 1;
        end
    end
    
    if n_evento ~= 0
        j = j + eventi;
    else
        j = j+1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GET PEAK EVENTO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (n_evento ~= 0)
        peaks_array_supply = sortrows(peaks_array_supply, 2, "descend");
        
        peak_array(peaks_array_supply(1,4),:) = peaks_array_supply(1, :);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ripulisco array e struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1: length(frames_states_array_ripuliti(:,1))
        stato = 0;

        %almeno uno dei due contiene un massimo
        for j = 1 : length(peak_array(:,1))
            if i == peak_array(j, 4)
                stato = 1;    
            end
        end

        if stato == 0
            frames_states_array_ripuliti(i,2:7) = 0;
            
            %cerco nella struct
            fname = append("frame", num2str(frame_start+fr_diff+i-1));
            frames_states_struct_ripuliti.(fname).massimi  = 0;
            frames_states_struct_ripuliti.(fname).minimi  = 0;
            frames_states_struct_ripuliti.(fname).area_max  = 0;
            frames_states_struct_ripuliti.(fname).area_min  = 0;
            frames_states_struct_ripuliti.(fname).num_evento  = 0;
        end
    end

end










