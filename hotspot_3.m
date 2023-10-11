function [max_hotspot, min_hotspot, z] = hotspot_3 (filename, m1, mdiff, soglia_max, soglia_min, varargin)
    num = length(varargin);

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
        end
    end

    %Cartella per salvataggio dati
    check = exist(['ThermoResults\',filename]);
    if check ~= 7
        mkdir(['ThermoResults\',filename]);
    end

    path = [pwd,'\ThermoResults\',filename,'\',];

    %Trova hotspots
    [Rows, Columns] = size (mdiff);
    [data_x, data_y] = meshgrid( 1:Columns, 1:Rows);
    dati = [data_x, data_y, mdiff];

        %smoothing
        if smooth == 1
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
        
        max_hotspot = [max_hotspot_coord, z(max_hotspot_coord)];
        min_hotspot = [min_hotspot_coord, z(min_hotspot_coord)];
    %Pulisci workspace
    clear S;
end