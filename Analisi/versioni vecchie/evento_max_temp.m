function [peak_max, peak_min] = evento_max_temp(frames_states)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-12-28 Last modification: 2023-12-28
%Authors: Cristina Zuccali
%evento_max_temp(frames_states, n_evento)
%   'frame_states' = is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame
%
%   peak_max = (position, value, # associated event group) of maximum of max (hot points) of an event
%   peak_min = (position, value, # associated event group) of minimum of min (cold points) of an event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%iniziazlizzo variabili
peak_max = zeros(0, 4);
peak_min = zeros(0, 4);

%prendo massimi e minimi di ogni evento
j = 1;
while j <= length(frames_states(:,8))
    n_evento = frames_states(j, 8);
    eventi = 0;
    max_peaks_array = zeros(0, 3); %coord, value, index
    min_peaks_array = zeros(0, 3); %coord, value, index
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GET EVENTO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1 : length(frames_states(:,1))
        if (frames_states(i, 8) == n_evento & n_evento ~= 0)
            max_peaks_array(end+1, 1) = frames_states(i, 2);
            max_peaks_array(end, 2) = frames_states(i, 4);
            max_peaks_array(end, 3) = frames_states(i, 8);
            max_peaks_array(end, 4) = i;
            min_peaks_array(end+1, 1) = frames_states(i, 3);
            min_peaks_array(end, 2) = frames_states(i, 5);
            min_peaks_array(end, 3) = frames_states(i, 8);
            min_peaks_array(end, 4) = i;
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
        max_peaks_array = sortrows(max_peaks_array, 2, "descend");
        min_peaks_array = sortrows(min_peaks_array, 2, "ascend");
        
        peak_max(end+1,:) = max_peaks_array(1, :);
        peak_min(end+1,:) = min_peaks_array(1, :);

    end

end