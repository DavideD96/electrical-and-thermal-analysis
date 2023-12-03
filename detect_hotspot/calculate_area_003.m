function [area_max, area_min, imsov] = calculate_area_003(imm, framestates, method, thresh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-02 Last modification: 2023-11-03
%Author: Cristina Zuccali
%calculate_area(imm, framestates, method, thresh)
%
%It calculates the area with 'method'.
%   imm = matrix of the frame;
%   framestates = array --> [max_coordinate, max_value, min_coordinate, min_value, state, time]
%   method = 'BiW', 'RGS', 'CWT'
%   thresh = threshold for RGS method
%
%   area_max = area of hot regions
%   area_min = area of cold regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Analisi con binarizzazione e calcolo area
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    area_max = 0;
    area_min = 0;
  
    %se c'è sia un massimo che un minimo stampo l'immagine
        controllo_stato = 0;
        
    %se c'è un massimo lascio la matrice come è
        if framestates(1, 2) ~= 0

            controllo_stato = controllo_stato + 1;
            imm_pos = max(imm, 0);
            
            if prod(method == 'BiW')
                BW = imbinarize(imm_pos, "global");
            
            elseif prod(method == 'RGS')
                BW = regional_growth_segmentation_2(framestates(1,1), 1, imm_pos, thresh);

            elseif prod(method == 'CWT')
                %punto di massimo per ogni scala e lo salvo
                scala_max = 20;
                max_ampiezze_coeff = zeros(scala_max, 3);
                
                %coefficienti a vari fattori di scala e salvo l'array delle
                %massime ampiezze
                for i=1:1:scala_max
                    cwtstruct = cwtft2(imm_pos,'wavelet','mexh','scales',1:1:scala_max);
                    ampiezze_coef = abs(cwtstruct.cfs(:,:,1,i,1)).^2;

                    max_array_coord = find(imregionalmax(ampiezze_coef));
                    max_array = [max_array_coord, ampiezze_coef(max_array_coord)];

                    massimo = sortrows(max_array, 2, 'descend');

                    max_ampiezze_coeff(i, :) = [massimo(1,1), massimo(1,2), i];                          
                end
                
                %trovo il fattore di scala per cui ho le ampiezze massime e
                %salvo
                massimo = sortrows(max_ampiezze_coeff, 2, 'descend');
                fattore_scala = massimo(1,3);
                BW = abs(cwtstruct.cfs(:,:,1,fattore_scala,1)).^2;
            end

            seD = strel('diamond', 1);
            BWfinal = imerode(BW, seD);
            BWfinal = imerode(BWfinal, seD);

            imsov_max=labeloverlay(imm_pos,BWfinal);
            
            %calcolo l'area
            area = regionprops(BWfinal, 'Area'); %perchè BiW binarizza tutta l'immagine e quindi trova tutte le regioni calde. Questo restituisce le aree separate.

            if isempty(area) == 1
                area_max = 0;
            else
                area_max = area.Area;
            end

        end

    %se c'è un minimo inverto il segno della matrice così da
    %poterlo vedere come bianco nell'immagine binaria
        if framestates(1, 4) ~= 0
            controllo_stato = controllo_stato + 1;
            imm_neg = max(-imm, 0);

            if prod(method == 'BiW')
                BW = imbinarize(imm_neg, "global");
            
            elseif prod(method == 'RGS')
                BW = regional_growth_segmentation_2(framestates(1,1), 1, imm_neg, thresh);

            elseif prod(method == 'CWT')
                %punto di massimo per ogni scala e lo salvo
                scala_max = 20;
                max_ampiezze_coeff = zeros(scala_max, 3);
                
                %coefficienti a vari fattori di scala e salvo l'array delle
                %massime ampiezze
                for i=1:1:scala_max
                    cwtstruct = cwtft2(-imm_pos,'wavelet','mexh','scales',1:1:scala_max);
                    ampiezze_coef = abs(cwtstruct.cfs(:,:,1,i,1)).^2;

                    max_array_coord = find(imregionalmax(ampiezze_coef));
                    max_array = [max_array_coord, ampiezze_coef(max_array_coord)];

                    massimo = sortrows(max_array, 2, 'descend');

                    max_ampiezze_coeff(i, :) = [massimo(1,1), massimo(1,2), i];                          
                end
                
                %trovo il fattore di scala per cui ho le ampiezze massime e
                %salvo
                massimo = sortrows(max_ampiezze_coeff, 2, 'descend');
                fattore_scala = massimo(1,3);
                BW = abs(cwtstruct.cfs(:,:,1,fattore_scala,1)).^2;
            end

            seD = strel('diamond', 1);
            BWfinal = imerode(BW, seD);
            BWfinal = imerode(BW, seD);

            imsov_min=labeloverlay(imm_neg,BWfinal);

            %calcolo l'area
            area = regionprops(BWfinal, 'Area'); %perchè BiW binarizza tutta l'immagine e quindi trova tutte le regioni fredde. Questo restituisce le area separate.
            if isempty(area)==1
                area_min = 0;
            else
            area_min = area.Area;
            end
        end

    %assegno imsov
    if controllo_stato == 2
        imsov = imsov_max + imsov_min;
    
    elseif framestates(1, 2) ~= 0
        imsov = imsov_max;
    
    elseif framestates(1, 4) ~= 0
        imsov = imsov_min;
    end

end

