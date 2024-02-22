function state = raggruppo_2eventi_003(frame_1, frame_2, Rows, Columns)
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
        state = [];

        eventi_1 = frame_1;
        eventi_2 = frame_2;
        eventi_2_new = [];
        [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
 
        %gli altri punti
        i = 1; %indice eventi del primo frame. 

        % NOOOOO Quelli che matchano nel secondo dovranno avere stesso indice.
        % esempio: max_coord1 = [234 312 12] significa che ho tre eventi nel
        % primo frame. Se nel secondo ho sempre tre eventi e il match dei secondi due, e non
        % del primo: max_coord2 = [0 311 13 452] NOOOOOOO

        while i <= length(eventi_1(:,1)) %ciclo sugli eventi del primo frame

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

                if eventi_1(i,2)*eventi_2(j,2) > 0      %picchi esistono e sono dello stesso tipo (è importante, pensaci!)
                    k = 1;
                    while k<=9 & stato_singolo == 0             
                        if x_2 == coord_primi(k,1) && y_2 == coord_primi(k,2)
                            stato_singolo = 1;
                            state = [state; i, j];
                        end
                       k = k+1;              
                    end                   
                end
                j = j + 1;
            end
            i = i +1;
        end
    end
end

