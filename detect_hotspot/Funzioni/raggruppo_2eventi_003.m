function [state] = raggruppo_2eventi_002(frame_1, frame_2, Rows, Columns)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-16 Last modification: 2024-01-17
%Author: Cristina Zuccali
%raggruppo_eventi(peak, type, frame_start)
%
%controlla se frame successivi detectano lo stesso evento
%
%
%   'state' = 1 if the two frames detect the same event, 0 if not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(frame_1) == 0 & isempty(frame_2) == 0
        numero_eventi_1 = length(frame_1(:,1));
        numero_eventi_2 = length(frame_2(:,1));
        state = 1;
    
        if numero_eventi_1 == numero_eventi_2
            eventi_1 = frame_1;
            eventi_2 = frame_2;
            [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
     
            %gli altri punti
            i = 1;
    
            while i <= length(eventi_1(:,1)) & state == 1 %ciclo sugli eventi del primo frame
                
                %Coordinate picco_1
                y_1 = data_y(eventi_1(i,1));
                x_1 = data_x(eventi_1(i,1));
    
                %Coordinate primi vicini
                coord_primi = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1)];
                
                stato_singolo = 0;
                j = 1;
                while j <= length(eventi_2(:,1)) & stato_singolo == 0
                    %Coordinate picco_2
                    y_2 = data_y(eventi_2(j,1));
                    x_2 = data_x(eventi_2(j,1));

                    if eventi_1(i,2)*eventi_2(j,2) > 0      %picchi esistono e sono dello stesso tipo
                        k = 1;
                        while k<=9 & stato_singolo == 0             
                            if x_2 == coord_primi(k,1) && y_2 == coord_primi(k,2)
                                eventi_2(j,:) = [];
                                eventi_1(i,:) = [];
                                stato_singolo = 1;
                            end
                           k = k+1;              
                        end                   
                    end
                    j = j + 1;
                end

                if stato_singolo == 0 %non è stato trovato il match
                    state = 0;
                end
            end
        end
    else
        state = 0;
    end
end

