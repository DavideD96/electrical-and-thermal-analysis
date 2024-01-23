function [state] = raggruppo_2eventi_diversi_005(frame_1, frame_2, Rows, Columns)
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
    
        %sono presenti lo stesso numero di eventi?
        if numero_eventi_1 == numero_eventi_2
            %sono presenti lo stesso numero di eventi

            %variabili di appoggio
            eventi_1 = frame_1;
            eventi_2 = frame_2;
            [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    
            %il primo a parte perchè mi dice se devo cercare la stessa
            %configurazione o quella invertita
            y_1 = data_y(eventi_1(1,1));
            x_1 = data_x(eventi_1(1,1));
            
            %Coordinate primi vicini
            coord_primi = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1)];
    
            %cerco sul frame 2
            stato_singolo = 0;
            state = 1;
            j = 1;
            while j <= length(eventi_2(:,1)) & stato_singolo == 0
                %Coordinate picco_2
                y_2 = data_y(eventi_2(j,1));
                x_2 = data_x(eventi_2(j,1));
                
                if eventi_1(1,2)*eventi_2(j,2) > 0      %picchi esistono e sono dello stesso tipo
                    k = 1;
                    while k<=9 & stato_singolo == 0             
                        if x_2 == coord_primi(k,1) && y_2 == coord_primi(k,2)
                            eventi_2(j,:) = [];
                            eventi_1(1,:) = [];
                            stato_singolo = 1;
                            tipo = 1;
                        end
                       k = k+1;              
                    end
                elseif eventi_1(1,2)*eventi_2(j,2) < 0 %i picchi sono del segno opposto
                    k = 1;
                    while k<=9 & stato_singolo == 0             
                        if x_2 == coord_primi(k,1) && y_2 == coord_primi(k,2)
                            eventi_2(j,:) = [];
                            eventi_1(1,:) = [];
                            stato_singolo = 1;
                            tipo = -1;
                        end
                       k = k+1;              
                    end
                end
                j = j+ 1;
            end
    
            if stato_singolo == 0 %non è stato trovato il match
                    %disp('ciao1')
                    state = 0;
            end 

            %gli altri punti
            i = 1;
            while i <= length(eventi_1(:,1)) & state == 1 %se lo state ~= 1 la prima ricerca è fallita
                
                %Coordinate picco_1
                y_1 = data_y(eventi_1(i,1));
                x_1 = data_x(eventi_1(i,1));
    
                %Coordinate primi vicini
                coord_primi = [ x_1, y_1; (x_1 - 1) (y_1 - 1); (x_1) (y_1 - 1); (x_1 + 1) (y_1 - 1); (x_1 - 1) (y_1); (x_1 + 1) (y_1); (x_1 - 1) (y_1 + 1); (x_1) (y_1 + 1); (x_1 + 1) (y_1+1)];
                
                stato_singolo = 0;
                j=1;
                while j <= length(eventi_2(:,1)) & stato_singolo == 0
                    %Coordinate picco_2
                    y_2 = data_y(eventi_2(j,1));
                    x_2 = data_x(eventi_2(j,1));

                    if tipo == 1 %stesso tipo
                        if eventi_1(i,2)*eventi_2(j,2) > 0
                            %disp('ciao')%picchi esistono e sono dello stesso tipo
                            for k = 1 : length(coord_primi(:,1))            
                                if x_2 == coord_primi(k,1) && y_2 == coord_primi(k,2)
                                    eventi_2(j,:) = [];
                                    eventi_1(i,:) = [];
                                    stato_singolo = 1;
                                    break
                                end             
                            end
                        end
    
                    elseif tipo == -1 %tipo diverso
                        if eventi_1(i,2)*eventi_2(j,2) < 0 %i picchi sono del segno opposto
                            % disp('ciao')
                            for k = 1 : length(coord_primi(:,1))            
                                if x_2 == coord_primi(k,1) && y_2 == coord_primi(k,2)
                                    eventi_2(j,:) = [];
                                    eventi_1(1,:) = [];
                                    stato_singolo = 1;
                                    break
                                end          
                            end
                        end
                    end
                    j = j + 1;
                end

                if stato_singolo == 0 %non è stato trovato il match
                    %disp('ciao1')
                    state = 0;
                    break
                end
            end
        else
            %gli eventi sono diversi quindi non sono simili
            %disp('ciao2')
            state = 0;
        end
    else
        %disp('ciao3')
        %gli eventi sono diversi quindi non sono simili
        state = 0;
    end
end

