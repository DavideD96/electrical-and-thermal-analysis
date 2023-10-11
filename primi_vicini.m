function [peak, state] = primi_vicini(peak, type, z)
    %peak è 1x2: coord_mdiff mdiff(coord_mdiff)
    %type indica se peak è un massimo o un minimo: max -> type = 1, min ->
    %type = 0
    %z sono i valori di delta T
    
    %Coordinate massimo
    [Rows, Columns] = size (z);
    y = ceil(peak(1,1)/Rows); %%floor up
    x = peak(1,1) - Rows*(y-1);
        
    %Controllo i primi vicini
    state = 1;
    
    coord_primi = [ x-1 y-1; x y-1; x+1 y-1; x-1 y; x+1 y; x-1 y+1; x y+1; x+1 y+1];
    i = 1;
    
    if type == 1
        while state == 1 && i<8
            if z( coord_primi(i,1), coord_primi(i,2)) < 0
                state = 0;
            end
            i = i+1;              
        end
        
    elseif type == 0     
        while state == 1 && i<8
            if z( coord_primi(i,1), coord_primi(i,2)) > 0
                state = 0;
            end
            i = i+1;              
        end
    
    else
        disp('Errore: type può essere solo 1 (max) o 0 (min)');
    end
end

