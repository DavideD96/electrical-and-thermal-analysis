function [area_max, area_min, imsov, centroid] = calculate_area_003(imm, framestates, method, thresh, dec_centroid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-02 Last modification: 2023-11-03
%Author: Cristina Zuccali
%calculate_area(imm, framestates, method, thresh)
%
%It calculates the area with 'method' and as an opition the centroid.
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

    %calcolo il centro di massa
    if dec_centroid == 1
        centroid = regionprops(BW, imm, {'Centroid, ''WeightedCentroid'});
    end

end

