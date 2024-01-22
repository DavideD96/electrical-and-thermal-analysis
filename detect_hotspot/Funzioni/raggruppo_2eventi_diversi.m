function [state] = raggruppo_2eventi_diversi(peak_1_coord, peak_1_value, peak_2_coord, peak_2_value, Rows, Columns)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-31 Last modification: 2023-11-02
%Author: Cristina Zuccali
%raggruppo_eventi(peak, type, frame_start)
%
%controlla se frame successivi detectano lo stesso evento
%
%   'peak_1' = is a line vector of the peak of start frame--> [coordinate, value]
%   'peak_2' = is a line vector of the peak of next frame--> [coordinate, value]
%
%   'state' = 1 if the two frames detect the same event, 0 if not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Coordinate picco_1
    y_1 = ceil(peak_1_coord/Rows); %%floor up
    x_1 = peak_1_coord - Rows*(y_1-1);

    %Coordinate picco_2
    y_2 = ceil(peak_2_coord/Rows); %%floor up
    x_2 = peak_2_coord - Rows*(y_2-1);
        
    %Coordinate primi vicini
    coord_primi = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1)];
    
    %inizializzo 
    state = 0;
    i = 1;
    
    if peak_1_value ~= 0 & peak_2_value ~= 0      %controllo che i due picchi esistano
            while state == 0 && i<8
                
                if x_2 == coord_primi(i,1) && y_2 == coord_primi(i,2)
                    state = 1;
                end

                i = i+1;              
            end
    end

end

