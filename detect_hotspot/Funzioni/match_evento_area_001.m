function stato = match_evento_area_001(frame,coord,neigh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-02-21 Last modification: 2024-02-21
%Author: Cristina Zuccali, Davide Decastri
%
%controlla se i il frame contiene eventi all'interno dell'area indicata
%dall'utente
%
%   'frame' = coordinate dei max e min del frame
%   'neigh' = 1,2. 1 uses nearest neigh, 2 uses 2nd nearest neigh
%   'coord' = [x,y] vector contatining coordinate of cluster centre.
%
%   'state' = 1 if the two frames detect the same event, 0 if not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(frame) == 0 

        eventi = frame;
        x_1 = coord(1,1);
        y_1 = coord(1,2);

        if neigh == 1
            coord_forComp = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1)];
        elseif neigh == 2
            coord_forComp = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1);...
                (x_1-1) (y_1 - 2); (x_1) (y_1 - 2); (x_1+1) (y_1 - 2); (x_1-1) (y_1 + 2); (x_1) (y_1 + 2); (x_1+1) (y_1 + 2); ... % tre punti sotto, in orizzontale
                (x_1-2) (y_1 - 1); (x_1 - 2) (y_1); (x_1 - 2) (y_1 + 1); (x_1 + 2) (y_1 - 1); (x_1 + 2) (y_1); (x_1 + 2) (y_1 + 1);]; % tre punti ai lati, in verticale
        end
        
        stato = 0;
        i = 1;
        while i <= length(eventi(:,1)) && stato == 0 %ciclo sugli eventi 
            j = 1;
            while j <= size(coord_forComp,1) && stato == 0 %ciclo sui vicini (primi o secondi che siano)
                if coord_forComp(j,1) == eventi(i,1) && coord_forComp(j,2) == eventi(i,2)
                    stato = 1; %match trovato!!!
                end
                j = j+1;
            end
            i = i+1;
        end 
    end
end

