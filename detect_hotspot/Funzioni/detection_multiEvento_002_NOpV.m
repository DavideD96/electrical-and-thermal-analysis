function [max_evento, min_evento, area_max, area_min, imsov] = detection_multiEvento_002_NOpV(max_hotspot, min_hotspot, point_state_max, point_state_min, imrec, mdiff, Rows, Columns)

%This program receives max_hotspot containing the coordinates of all
%overthershold pixels. Then, it checks with primi_vicini and tries to
%separate the areas associated with each event. max_evento is essentially
%the same of max_hotspot, but with excluding non-separated events.
%
% max_hotspot = 2D array containing event coordinate (1st column) and value
%               (2nd column)

%strel da diamond a disk: i risultati non cambiano ma è più logico!!!!!!!!! 
    area_max = zeros(0,1);
    area_min = zeros(0,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PASSO 2: binarizzazione dell'immagine con metodo Otsu
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %MASSIMI
    if point_state_max ==1
        %salvo punto negli eventi
        max_evento = max_hotspot; %then, we will erase max_evento point by point, by means of a selection procedure
    
        %miglioramento immagine
        n_puntoEvento = 1;
        name = append("evento_", num2str(n_puntoEvento));
    
        BW_strel = imbinarize(imrec, "global");
        seD = strel('disk', 1); %prima era diamond
        BWfinal_max = imerode(BW_strel, seD);
        
        %variabili per controllo degli altri punti
        [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
        x_ref = data_x(max_evento(1,1));
        y_ref = data_y(max_evento(1,1));
    
        %label principale
        BWselezionato_max_evento.(name) = bwselect(BWfinal_max, x_ref, y_ref); %seleziono l'oggetto che è stato formato nell'immagine binarizzata
                                                                               % in corrispondenza del picco trovato in precedenza
        label_max.(name) = bwlabel(BWselezionato_max_evento.(name));
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %PASSO 3: controllo i primi vicini degli altri punti, controllo se stanno
        %sullo stesso oggetto del principale oppure no
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        j = 1;
        while j <=  (length(max_evento(:,1)))
            x_ref = data_x(max_evento(j,1));
            y_ref = data_y(max_evento(j,1));

            name_confronto = append("evento_", num2str(j));

            BWselezionato_max_evento.(name_confronto) = bwselect(BWfinal_max, x_ref, y_ref); %seleziono oggetto anche per l'evento da cfr
            label_max.(name_confronto) = bwlabel(BWselezionato_max_evento.(name_confronto));
            numero_oggetti = bwconncomp(BWfinal_max);
            numero_oggetti_before = numero_oggetti.NumObjects;
        
            i = j + 1;
            while i <= length(max_evento(:,1))
                x_controllo = data_x(max_evento(i,1));
                y_controllo = data_y(max_evento(i,1));
    
                %controllo che sia pixel bianco
                if BWfinal_max(y_controllo, x_controllo) == 1
                    %primi vicini
                    state = 1; %primi_vicini(max_evento(i,:), 1, mdiff); %verifico che sia rispettata la condizione sui primi vicini
                                                                     %(cioè che sia un vero max)  
                    if state == 1
                        %controllo se è sullo stesso oggetto del principale
                        if label_max.(name_confronto)(y_ref, x_ref) == label_max.(name_confronto)(y_controllo, x_controllo)
                            %sono sullo stesso oggetto provo a dividere
                            %verfica solidità
                            solidita = regionprops(BWselezionato_max_evento.(name_confronto), 'Solidity');

                            if isempty(solidita) == 0
                                if solidita.Solidity(1,1) < 0.80
                                    %è concavo
                                    BWfinal_max_erode = imerode(BWselezionato_max_evento.(name_confronto), seD);
                
                                    %conto nuovi oggetti
                                    numero_oggetti = bwconncomp(BWfinal_max_erode);
                                    numero_oggetti = numero_oggetti.NumObjects;
                                    %se ho più di un oggetto (divisione riuscita), assegno
                                    %nuove aree
                                    BWselezionato = bwselect(BWfinal_max_erode, x_controllo, y_controllo);
                                    label = bwlabel(BWselezionato);
        
                                    if numero_oggetti > numero_oggetti_before
                                        BWfinal_max = BWfinal_max_erode;
                                        %controllo se è stato diviso !!!!!!
                                        if label(y_ref, x_ref) ~= label(y_controllo, x_controllo)
                                            %divisione riuscita        
                                            numero_oggetti_before = numero_oggetti;
                                            n_puntoEvento = n_puntoEvento + 1;
                                            i = i + 1;
                                        else
                                            %si trova ancora sullo stesso
                                            %oggetto, quindi non è un
                                            %evento
                                            max_evento(i,:) = [];
                                        end

                                    else
                                        %gli oggetti non sono stati divisi
                                        %quindi non è un evento
                                        max_evento(i,:) = [];
                                    end
                                else
                                    %l'oggetto non è concavo quindi non è un evento
                                    max_evento(i,:) = [];
                                end

                            else
                                %l'oggetto non è concavo quindi non è un evento
                                max_evento(i,:) = [];
                            end

                        else
                            %gli oggetti sono già divisi
                            n_puntoEvento = n_puntoEvento + 1;
                            i = i + 1;
                        end

                    else
                        %non ha superato il test dei primi vicini, quindi
                        %non è un evento
                        max_evento(i,:) = [];
                    end

                else
                    %non è con pixel 1, quindi
                    %non è un evento
                    max_evento(i,:) = [];
                end
            end
            j = j + 1;
        end

        %immagine per sovrapposizione
        imsov_max = labeloverlay(imrec,BWfinal_max);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %PASSO 4: calcolo area e salvo
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1 : length(max_evento(:,1))
            name = append("evento_", num2str(i));
            area = regionprops(BWselezionato_max_evento.(name), "Area");
            
            if isempty(area) == 0
                area_max(end+1,1) = area.Area;
            else
                area_max(end+1,1) = 0;
            end
        end

        else
            %se non ci sono metto a zero
            max_evento(1,:) = 0;
            area_max(1,1) = 0;
    end
    
    %MINIMI
    if point_state_min ==1
        %salvo punto negli eventi
        min_evento = min_hotspot;
    
        %miglioramento immagine
        n_puntoEvento = 1;
        name = append("evento_", num2str(n_puntoEvento));
    
        BW_strel = imbinarize(-imrec, "global");
        seD = strel('disk', 1); %prima era diamond
        BWfinal_min = imerode(BW_strel, seD);
        
        %variabili per controllo degli altri punti
        [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
        x_ref = data_x(min_evento(1,1));
        y_ref = data_y(min_evento(1,1));
        %coordinate evento
    
        %label principale
        BWselezionato_min_evento.(name) = bwselect(BWfinal_min, x_ref, y_ref);
        label_min.(name) = bwlabel(BWselezionato_min_evento.(name));
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %controllo i primi vicini degli altri punti, controllo se stanno
        %sullo stesso oggetto del principale oppure no
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        j = 1;
        while j <= (length(min_evento(:,1)))
            x_ref = data_x(min_evento(j,1));
            y_ref = data_y(min_evento(j,1));

            name_confronto = append("evento_", num2str(j));

            BWselezionato_min_evento.(name_confronto) = bwselect(BWfinal_min, x_ref, y_ref);
            label_min.(name_confronto) = bwlabel(BWselezionato_min_evento.(name_confronto));
            numero_oggetti = bwconncomp(BWfinal_min);
            numero_oggetti_before = numero_oggetti.NumObjects;
            
            i = j + 1;
            while i <= length(min_evento(:,1))
                x_controllo = data_x(min_evento(i,1));
                y_controllo = data_y(min_evento(i,1));
    
                %controllo che sia pixel bianco
                if BWfinal_min(y_controllo, x_controllo) == 1
                    %primi vicini
                    state = 1; %primi_vicini(min_evento(i,:), 0, mdiff);
    
                    if state == 1
                         if label_min.(name_confronto)(y_ref, x_ref) == label_min.(name_confronto)(y_controllo, x_controllo)
                            %sono sullo stesso oggetto provo a dividere
                            %verfica solidità
                            solidita = regionprops(BWselezionato_min_evento.(name_confronto), 'Solidity');
                            if isempty(solidita) == 0
                                if solidita.Solidity(1,1) < 0.80
                                    %è concavo
                                    BWfinal_min_erode = imerode(BWselezionato_min_evento.(name_confronto), seD);
                
                                    %conto nuovi oggetti
                                    numero_oggetti = bwconncomp(BWfinal_min_erode);
                                    numero_oggetti = numero_oggetti.NumObjects;
                                    %se ho più di un oggetto (divisione riuscita), assegno
                                    %nuove aree
                                    BWselezionato = bwselect(BWfinal_min_erode, x_controllo, y_controllo);
                                    label = bwlabel(BWselezionato);
        
                                    if numero_oggetti > numero_oggetti_before
                                        BWfinal_min = BWfinal_min_erode;
                                        %controllo se è stato diviso 
                                        if label(y_ref, x_ref) ~= label(y_controllo, x_controllo)
                                            %divisione riuscita        
                                            numero_oggetti_before = numero_oggetti;
                                            n_puntoEvento = n_puntoEvento + 1;
                                            i = i + 1;
                                        else
                                            min_evento(i, :) = [];
                                        end
                                    else
                                        min_evento(i, :) = [];
                                    end
                                else
                                    min_evento(i, :) = [];
                                end
                            else
                                min_evento(i, :) = [];
                            end
                        else
                            %gli oggetti sono già divisi
                            n_puntoEvento = n_puntoEvento + 1;
                            i = i + 1;
                        end
                    else
                        min_evento(i, :) = [];
                    end
                else
                    min_evento(i, :) = [];
                end
            end
            j = j + 1;
         end
         %immagine per sovrapposizione
         imsov_min = labeloverlay(-imrec, BWfinal_min);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %PASSO 4: calcolo area e salvo
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1 : length(min_evento(:,1))
            name = append("evento_", num2str(i));
            area = regionprops(BWselezionato_min_evento.(name), "Area");
            
            if isempty(area) == 0
                area_min(end+1,1) = area.Area;
            else
                area_min(end+1,1) = 0;
            end
        end

    else
        %se non ci sono metto a zero
        min_evento(1,:) = 0;
        area_min(1,1) = 0;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PASSO 5: imsov
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if point_state_max == 1 && point_state_min == 0
        imsov = imsov_max;
    elseif point_state_min == 1 && point_state_max == 0
        imsov = imsov_min;
    elseif point_state_max == 1 && point_state_min == 1
        imsov = imsov_max + imsov_min;
    else 
        imsov = 0;
    end

    
end

