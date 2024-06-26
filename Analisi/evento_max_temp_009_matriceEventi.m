function matriceEventi = evento_max_temp_009_matriceEventi(in_or_mid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-28 Last modification: 2023-12-6
%Authors: Cristina Zuccali
%evento_max_temp(frames_states, n_evento)
%
%   'frame_states' = this object is saved in 'Matrice_eventi_doppi' 
%               is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame

%   'frames_states_single' = same as 'frame_state', but without doubling each row. (indice di riga 1 corrisponde a DeltaT calcolata con mtotal(:,:,delay+fr_diff)-mtotal(:,:,delay))
%   'frame_struct' = struct containing 1 struct per each frame.
%
%   peak_max = (position, value, # associated event group, i, i_doppio) of maximum of max (hot points) of an event
%   peak_min = (position, value, # associated event group, i, i_doppio) of minimum of min (cold points) of an event
%   matrice eventi has [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% cd termoFiles_mat 
%     mtotalT = load("mtotalT.mat"); %timesDT has Nframes - fr_diff elements
%     mtotalT = cell2mat(struct2cell(mtotalT));
% cd ..ù

frames = load("frames.mat"); %timesDT has Nframes - fr_diff elements
Events = cell2mat(struct2cell(frames));

% 
% cd 'parameters'
% ThermalParameters_ = load('ThermalParameters.mat');
% ThermalParameters = ThermalParameters_.ThermalParameters;
% cd ..

% for i = 0 : length(fieldnames(frame_struct)) - 1
%     fname = append("frame", num2str(frame_start-fr_diff + fr_diff +  i));
%     Eventi_supp.(fname)=struct('tempo', 0, 'coordmax', 0, 'coordmin', 0, 'massimi', 0, 'minimi', 0, 'area_max', 0, 'area_min', 0, 'num_evento', 0);
% end

Nframes = size(Events,1);
ind_evt = 0;

matriceEventi = zeros(Nframes,8); %time, location max, location min, amplitude max, amplitude min, state (n° evento)

if in_or_mid == 0 %uso solo inizio per ogni evento
    % fname = append("frame", num2str(frame_start-fr_diff + fr_diff +  i));

    for i = 1:Nframes
        matriceEventi(i,1) = Events(i,1);
        if Events(i,2) ~= 0 || Events(i,3) ~= 0
            if Events(i,8) ~= ind_evt
                matriceEventi(i,:) = Events(i,:);
                ind_evt = matriceEventi(i,8);
            end
        end
    end
else


end

cd termoFiles_mat
save('matriceEventi',"matriceEventi") %
cd ..
end