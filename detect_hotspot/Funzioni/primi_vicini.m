function [state] = primi_vicini(peak, type, z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-11 Last modification: 2023-11-02
%Author: Cristina Zuccali
%primi_vicini(peak, type, z)
%
%It makes a test on minima and maxima in a frame: it tests if the peak is
%surrounded by value with the same sign. (only 1 peak per time?)
%
%   'peak' = is a line vector --> [coordinate, value]
%   'type' = 1 if the peak is a maximum, 0 if the peak is a minimum
%   'z' = array of the value of the considered frame
%
%   'state' = 1 if the test succeed, 0 if the test failed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Coordinate massimo
    [Rows, Columns] = size (z);
    y = ceil(peak(1,1)/Rows); %%floor up
    x = peak(1,1) - Rows*(y-1);
        
    %Controllo i primi vicini
    state = 1;
    
    coord_primi = [ x-1 y-1; x y-1; x+1 y-1; x-1 y; x+1 y; x-1 y+1; x y+1; x+1 y+1];
    i = 1;

    if prod(prod(coord_primi)) == 0 %aggiunto da DD per evitare eventi al bordo
        state = 0;
        return
    end
    
    if type == 1                
        if any(coord_primi(:,1) > Rows) || any(coord_primi(:,1) < 0) || any(coord_primi(:,2) > Columns) || any(coord_primi(:,2) < 0)
            state = 0; %non detecto eventi sui bordi
        else
            while state == 1 && i<8
                if z(coord_primi(i,1), coord_primi(i,2)) < 0
                    state = 0;
                end
                i = i+1;              
            end
       end
        
    elseif type == 0   
        if any(coord_primi(:,1) > Rows) || any(coord_primi(:,1) < 0) || any(coord_primi(:,2) > Columns) || any(coord_primi(:,2) < 0)
            state = 0; %non detecto eventi sui bordi
        else
            while state == 1 && i<8
                if z( coord_primi(i,1), coord_primi(i,2)) > 0
                    state = 0;
                end
                i = i+1;              
            end
        end
    
    else
        disp('Errore: type può essere solo 1 (max) o 0 (min)');
    end
end

