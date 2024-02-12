function [peak_max, peak_min, Eventi_supp, matriceEventi] = evento_max_temp_007_matriceEventi(frames_states, frames_states_single, frame_struct, frame_start, fr_diff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-28 Last modification: 2023-12-6
%Authors: Cristina Zuccali
%evento_max_temp(frames_states, n_evento)
%   'frame_states' = is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame
%
%   peak_max = (position, value, # associated event group, i, i_doppio) of maximum of max (hot points) of an event
%   peak_min = (position, value, # associated event group, i, i_doppio) of minimum of min (cold points) of an event
%   matrice eventi has [time, state(1/0), delta_T principale, gruppoEvento]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%iniziazlizzo variabili
frames_states_supp = frames_states;
peak_max = zeros(length(frames_states_supp(:,1)), 5);
peak_min = zeros(length(frames_states_supp(:,1)), 5);
matriceEventi = zeros(length(frames_states_supp(:,1)), 3);

for i = 0 : length(fieldnames(frame_struct)) - 1
    fname = append("frame", num2str(frame_start + fr_diff +  i));
    Eventi_supp.(fname)=struct('tempo', 0, 'massimi', 0, 'minimi', 0, 'area_max', 0, 'area_min', 0, 'num_evento', 0);
end

%prendo massimi e minimi di ogni evento
j = 1;
indice = 0;
while j <= length(frames_states_supp(:,8))
    indice = indice + 1;

    n_evento = frames_states_supp(j, 8);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GET EVENTO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if n_evento ~= 0
        max_peaks_array = zeros(0, 5); %coord, value, evento, index
        min_peaks_array = zeros(0, 5); %coord, value, evento, index

        max_peaks_array(end+1, 1) = frames_states_supp(j, 2);
        max_peaks_array(end, 2) = frames_states_supp(j, 4);
        max_peaks_array(end, 3) = frames_states_supp(j, 8);
        max_peaks_array(end, 5) = indice;

        min_peaks_array(end+1, 1) = frames_states_supp(j, 3);
        min_peaks_array(end, 2) = frames_states_supp(j, 5);
        min_peaks_array(end, 3) = frames_states_supp(j, 8);
        min_peaks_array(end, 5) = indice;
                    
        for k = 1 : length(frames_states_single(:,1))
            if (frames_states_single(k, 1) == frames_states_supp(j, 1)) %controllo sui tempi
                max_peaks_array(end, 4) = k;
                min_peaks_array(end, 4) = k;
            end
        end

        frames_states_supp(j,:) = [];

        i = j;
        while i <= length(frames_states_supp(:,1))
            
            if (frames_states_supp(i, 8) == n_evento & n_evento ~= 0)
                indice = indice + 1;
                max_peaks_array(end+1, 1) = frames_states_supp(i, 2);
                max_peaks_array(end, 2) = frames_states_supp(i, 4);
                max_peaks_array(end, 3) = frames_states_supp(i, 8);
                max_peaks_array(end, 5) = indice;
    
                min_peaks_array(end+1, 1) = frames_states_supp(i, 3);
                min_peaks_array(end, 2) = frames_states_supp(i, 5);
                min_peaks_array(end, 3) = frames_states_supp(i, 8);
                min_peaks_array(end, 5) = indice;
                            
                for k = 1 : length(frames_states_single(:,1))
                    if (frames_states_single(k, 1) == frames_states_supp(i, 1)) %controllo sui tempi
                        max_peaks_array(end, 4) = k;
                        min_peaks_array(end, 4) = k;
                    end
                end
    
                frames_states_supp(i,:) = [];
            else
                i = i + 1;
            end
        end

        %selezione rappresentante

        max_peaks_array = sortrows(max_peaks_array, 2, "descend");
        min_peaks_array = sortrows(min_peaks_array, 2, "ascend");

        if max_peaks_array(1, 2) >= abs(min_peaks_array(1,2))
            peak_max(max_peaks_array(1,5),:) = max_peaks_array(1, :);

            peak_min(max_peaks_array(1,5), 1) = frames_states_single(max_peaks_array(1,4), 3);
            peak_min(max_peaks_array(1,5), 2) = frames_states_single(max_peaks_array(1,4), 5);
            peak_min(max_peaks_array(1,5), 3) = frames_states_single(max_peaks_array(1,4), 8);
            peak_min(max_peaks_array(1,5), 5) = max_peaks_array(1, 5);
            peak_min(max_peaks_array(1,5), 4) = max_peaks_array(1, 4);

            %riempio con i massimi
            matriceEventi(max_peaks_array(1,5), 1) = frames_states_single(max_peaks_array(1,4), 1);
            matriceEventi(max_peaks_array(1,5), 2) = 1;
            matriceEventi(max_peaks_array(1,5), 3) = frames_states_single(max_peaks_array(1,4), 4);
            matriceEventi(max_peaks_array(1,5), 4) = frames_states_single(max_peaks_array(1,4), 8);

        else
            peak_min(min_peaks_array(1,5),:) = min_peaks_array(1, :);

            peak_max(min_peaks_array(1,5), 1) = frames_states_single(min_peaks_array(1,4), 2);
            peak_max(min_peaks_array(1,5), 2) = frames_states_single(min_peaks_array(1,4), 4);
            peak_max(min_peaks_array(1,5), 3) = frames_states_single(min_peaks_array(1,4), 8);
            peak_max(min_peaks_array(1,5), 5) = min_peaks_array(1, 5);
            peak_max(min_peaks_array(1,5), 4) = min_peaks_array(1, 4);

            %riempio con i minimi
            matriceEventi(min_peaks_array(1,5), 1) = frames_states_single(min_peaks_array(1,4), 1);
            matriceEventi(min_peaks_array(1,5), 2) = 1;
            matriceEventi(min_peaks_array(1,5), 3) = frames_states_single(min_peaks_array(1,4), 5);
            matriceEventi(min_peaks_array(1,5), 4) = frames_states_single(min_peaks_array(1,4), 8);
        end

        fname = append("frame", num2str(frame_start + fr_diff +  max_peaks_array(1,4) - 1));
        Eventi_supp.(fname).tempo  = frame_struct.(fname).tempo;
        Eventi_supp.(fname).massimi  = frame_struct.(fname).massimi;
        Eventi_supp.(fname).minimi  = frame_struct.(fname).minimi;
        Eventi_supp.(fname).area_max  = frame_struct.(fname).area_max;
        Eventi_supp.(fname).area_min = frame_struct.(fname).area_min;
        Eventi_supp.(fname).num_evento  = frame_struct.(fname).num_evento;

        %matrice eventi
        
        

    else
        j = j+1;
    end
end
end