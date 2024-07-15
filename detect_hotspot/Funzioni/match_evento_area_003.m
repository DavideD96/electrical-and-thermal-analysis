function stato = match_evento_area_003(frame,coord,neigh,ThermalParameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-02-21 Last modification: 2024-02-21
%Author: Cristina Zuccali, Davide Decastri
%
%controlla se i il frame contiene eventi all'interno dell'area indicata
%dall'utente (basta che uno di essi matchi)
%
%   'frame' = array containing info about event detection (time,
%           max_coord, min_coordinate, max, min, area_max, 
%           area_min, state)
%   'neigh' = 1,2. 1 uses nearest neigh, 2 uses 2nd nearest neigh
%   'coord' = [x,y] vector contatining coordinate of cluster centre.
%             [colonna,riga]
%
%   'state' = 1 if the two frames detect the same event, 0 if not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eventi = frame; %matrice n-righe 2 colonne [coordinate, amplitudes]

%%%%%%% tolto per ridurre tempi di esecuzione in chiamate ripetute %%%%%%%%
% cd parameters
% ThermalParameters_ = load('ThermalParameters.mat');
% ThermalParameters = ThermalParameters_.ThermalParameters;
% cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Columns = ThermalParameters.Columns;
Rows = ThermalParameters.Rows;

%[data_x, data_y] = meshgrid(1:Columns, 1:Rows);

x_1 = coord(1,1); %coord del punto selezionato
y_1 = coord(1,2); %coord del punto selezionato

if neigh == 1
    coord_forComp = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1)];
elseif neigh == 2
    coord_forComp = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1);...
        (x_1-1) (y_1 - 2); (x_1) (y_1 - 2); (x_1+1) (y_1 - 2); (x_1-1) (y_1 + 2); (x_1) (y_1 + 2); (x_1+1) (y_1 + 2); ... % tre punti sotto, in orizzontale
        (x_1-2) (y_1 - 1); (x_1 - 2) (y_1); (x_1 - 2) (y_1 + 1); (x_1 + 2) (y_1 - 1); (x_1 + 2) (y_1); (x_1 + 2) (y_1 + 1);]; % tre punti ai lati, in verticale
end

stato = 0;

if any(eventi) %qualche evento (nuovo)?
    
    i = 1;
    while i <= size(eventi(:,1),1) && stato == 0 %ciclo sugli eventi 

        if eventi(i,1) ~= 0

        y_ev = ceil(eventi(i,1)/Rows);%data_y(eventi(i,1));
        x_ev = eventi(i,1) - Rows*(y_ev-1);%data_x(eventi(i,1));

        j = 1;
            while j <= size(coord_forComp,1) && stato == 0 %ciclo sui vicini (primi o secondi che siano)
                if coord_forComp(j,1) == x_ev && coord_forComp(j,2) == y_ev
                    stato = 1; %match trovato!!!
                    return
                end
                j = j+1;
            end

        end
        i = i+1;
    end
end

end

