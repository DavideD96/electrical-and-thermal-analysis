function [max_hotspot, min_hotspot, z] = hotspot_3 (mdiff, soglia_max, soglia_min, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-11 Last modification: 2023-10-16
%Author: Cristina Zuccali
%hotspot_3 (filename, m1, mdiff, soglia_max, soglia_min, varargin)
%
%Return the data of maxima and minima of the matrix mdiff. Minima and
%maxima are selected with two different thresholds.
%
%   'mdiff' = 2D array (in our case array of temperatures variations in the selected region
%           between fr_evento+fr_diff and fr_evento)
%   'soglia_max' = threshold for the selection of maxima
%   'soglia_min' = threshold for the selection of minima
%
%   'varargin' : there is the possibility of smooth mdiff data
%               ('smoothing', 1) --> smoothing of mdiff data
%               ('smoothing', 0) --> mdiff is left invariate
%
%   'max_hotspot' = array of maxima --> [coordinate, value]
%   'min_hotspot' = array of minima --> [coordinate, value]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    num = length(varargin);
    smooth_ = 0;

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth_ = varargin{k+1}; %1 = smooth, 0 = grezzo
        end
    end

    %Trova hotspots
    [Rows, Columns] = size (mdiff);
    [data_x, data_y] = meshgrid( 1:Columns, 1:Rows);
    dati = [data_x, data_y, mdiff];

        %smoothing
        if smooth_ == 1
                dati = {data_x(1,:), data_y(:,1).'};

                [sval,p] = csaps(dati,mdiff.', [],dati);

                z= sval.';

                %Trova massimo
                max_hotspot_coord = find(imregionalmax(z));
                max_hotspot_coord = max_hotspot_coord(z(max_hotspot_coord) >= soglia_max);
              
                %Trova minimo
                min_hotspot_coord = find(imregionalmin(z));
                min_hotspot_coord = min_hotspot_coord(z(min_hotspot_coord) <= soglia_min);
                

        else
            z = mdiff;

                %Trova massimo
                max_hotspot_coord = find(imregionalmax(mdiff));
                max_hotspot_coord = max_hotspot_coord(mdiff(max_hotspot_coord) >= soglia_max);
                
                %Trova minimo
                min_hotspot_coord = find(imregionalmin(mdiff));
                min_hotspot_coord = min_hotspot_coord(mdiff(min_hotspot_coord) <= soglia_min);

        end

        %max_hotspot_coord
        max_hotspot = [max_hotspot_coord, z(max_hotspot_coord)];
        disp('hotspot dentro')
        max_hotspot
        min_hotspot = [min_hotspot_coord, z(min_hotspot_coord)];
    %Pulisci workspace
    %clear S;
end