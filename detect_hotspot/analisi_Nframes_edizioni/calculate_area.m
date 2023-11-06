function [area_max, area_min, imsov] = calculate_area(imm, framestates, method, thresh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-02 Last modification: 2023-11-02
%Author: Cristina Zuccali
%calculate_area(imm, framestates, method, thresh)
%
%It calculates the area with 'method'.
%   imm = matrix of the frame;
%   framestates = array --> [max_coordinate, max_value, min_coordinate, min_value, state, time]
%   method = 'BiW', 'RGS'
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
            
            if prod(method == 'BiW')
                BW = imbinarize(imm, "global");
            
            elseif prod(method == 'RGS')
                BW = regional_growth_segmentation_2(framestates(1,1), 1, imm, thresh);
            end

            seD = strel('diamond', 1);
            BWfinal = imerode(BW, seD);
            BWfinal = imerode(BWfinal, seD);

            imsov_max=labeloverlay(imm,BWfinal);
            
            %calcolo l'area
            area_max = bwarea(BWfinal);
        end

    %se c'è un minimo inverto il segno della matrice così da
    %poterlo vedere come bianco nell'immagine binaria
        if framestates(1, 4) ~= 0
            controllo_stato = controllo_stato + 1;

            if prod(method == 'BiW')
                BW = imbinarize(-imm, "global");
            
            elseif prod(method == 'RGS')
                BW = regional_growth_segmentation_2(framestates(1,1), 1, -imm, thresh);
            end

            seD = strel('diamond', 1);
            BWfinal = imerode(BW, seD);
            BWfinal = imerode(BW, seD);

            imsov_min=labeloverlay(-imm,BWfinal);

            %calcolo l'area
            area_min = bwarea(BWfinal);
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

