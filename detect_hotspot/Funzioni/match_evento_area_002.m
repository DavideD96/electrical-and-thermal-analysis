function stato = match_evento_area_002(frame,coord,neigh)
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
%
%   'state' = 1 if the two frames detect the same event, 0 if not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eventi_max = [frame(2),frame(4)]; %matrice n-righe 2 colonne [coordinate, amplitudes]
eventi_min = [frame(3),frame(5)]; 

cd parameters
ThermalParameters_ = load('ThermalParameters.mat');
ThermalParameters = ThermalParameters_.ThermalParameters;
cd ..

Columns = ThermalParameters.Columns;
Rows = ThermalParameters.Rows;

[data_x, data_y] = meshgrid(1:Columns, 1:Rows);

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

if eventi_max(1,2) ~= 0 
    
    i = 1;
    while i <= size(eventi_max(:,1),1) && stato == 0 %ciclo sugli eventi 

        y_ev = data_y(eventi_max(i,1));
        x_ev = data_x(eventi_max(i,1));
        j = 1;
        while j <= size(coord_forComp,1) && stato == 0 %ciclo sui vicini (primi o secondi che siano)
            if coord_forComp(j,1) == x_ev && coord_forComp(j,2) == y_ev
                stato = 1; %match trovato!!!
                return
            end
            j = j+1;
        end
        i = i+1;
    end 
end

if eventi_min(1,2) ~= 0 
    
    stato = 0;
    i = 1;
    while i <= size(eventi_min(:,1),1) && stato == 0 %ciclo sugli eventi 

        y_ev = data_y(eventi_min(i,1));
        x_ev = data_x(eventi_min(i,1));
        j = 1;
        while j <= size(coord_forComp,1) && stato == 0 %ciclo sui vicini (primi o secondi che siano)
            if coord_forComp(j,1) == x_ev && coord_forComp(j,2) == y_ev
                stato = 1; %match trovato!!!
            end
            j = j+1;
        end
        i = i+1;
    end 
end
end

