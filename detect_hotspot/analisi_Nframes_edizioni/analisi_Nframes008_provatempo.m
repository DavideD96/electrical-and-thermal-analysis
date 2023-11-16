function frame_states = analisi_Nframes008(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, method, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-11-06
%6th edition of analisi_Nframes
%Author: Cristina Zuccali
%analisi_Nframes(filename,Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, varargin)
%
%Added: centroid of frames with an event detected
%
% Save only the DWT coefficients and not the image
%
%   'filename' = principal part of the file name of frame (without number of frame and .CSV)
%   'Nframes' = number of frames to analyze
%   'frame_start' = number of start frame
%   'fr_diff' = difference beetwen frame to show the difference of
%               temperature (fr_diff = 2 means difference between consecutive frames)
%   'coordname' = name of file with coordinates of the wanted region
%   'soglia_max' = threshold for the selection of maxima
%   'soglia_min' = threshold for the selection of minima
%   'method' = method for the detection of the events (only 'ThreshNN'
%              implemented so far)
%
%   'varargin' : 
%       there is the possibility of smooth mdiff data
%               ('smoothing', 1) --> smoothing of mdiff data
%               ('smoothing', 0) --> mdiff is left invariate
%
%       for video production
%               ('makeVideo', 1) --> makes the video
%
%
%       for area detection
%               ('detecArea', 1) --> calculate the area
%
%       to choose the method for the spot characterization
%               ('AreaMetho', 'CWT') = it finds the 'scale' of the spot
%               ('AreaMetho', 'BiW') = binarization 
%               ('AreaMetho', 'RGS') = regional growth method
%               ('ThreshRGS', ...) for pixels selection in regional growth segmentation
%
%   'frame_states' = is an array --> [time [s], max_coordinate [n° pixel], min_coordinate [n° pixel], max_value, min_value, max_area, min_area, state]
%               where state = 0 means that there is no event in the frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    num = length(varargin);
    
    %PARAMETRI DI DEFAULT
    smooth = 0;
    method_area = 'BiW';
    soglia_diff = 0.8;
    area = 1;
    dec_centroid = 0;

    for k = 1:2:num
        if prod(varargin{k}=='smoothing')
            smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
        
        elseif prod(varargin{k}=='makeVideo')
            video = varargin{k+1}; % 1 = video

        elseif prod(varargin{k}=='dCentroid')
            dec_centroid = varargin{k+1}; % 1 = trova i centri di massa dei frame con evento

        elseif prod(varargin{k}=='detecArea')
            area = varargin{k+1}; % 1 = fai l'analisi delle aree
        
        elseif prod(varargin{k}=='AreaMetho')
            method_area = varargin{k+1};

        elseif prod(varargin{k}=='ThreshRGS')
            soglia_diff = varargin{k+1};
        end
    end

    %Cartella per salvataggio dati
    sub_folder = ['fStart', num2str(frame_start), '_fdiff_', num2str(fr_diff), '_Nframes_', num2str(Nframes) ,'\'];

     if prod(method_area == 'BiW')

        check = exist(['ThermoResults\',filename,'\BW\', sub_folder]);
        if check ~= 7
            mkdir(['ThermoResults\',filename,'\BW\', sub_folder]);
        end
        
        path = [pwd,'\ThermoResults\',filename,'\BW\',sub_folder];
    
     elseif prod(method_area == 'RGS')

        check = exist(['ThermoResults\',filename, '\RGS\', sub_folder]);
        if check ~= 7
            mkdir(['ThermoResults\',filename,'\RGS\', sub_folder]);
        end
        
        path = [pwd,'\ThermoResults\',filename,'\RGS\', sub_folder];

    elseif prod(method_area == 'CWT')

        check = exist(['ThermoResults\',filename, '\CWT\', sub_folder]);
        if check ~= 7
            mkdir(['ThermoResults\',filename,'\CWT\', sub_folder]);
        end
        
        path = [pwd,'\ThermoResults\',filename,'\CWT\', sub_folder];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendi dati e denoising
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %scelta parametri DWT
    wname = 'db4';
    level =1;
    
    %array per salvare i dati dei frame e temperature massime e minime
    %(coord, value)
    framestates = zeros(Nframes-fr_diff+1,8);
    max_min_temp = zeros(Nframes-fr_diff+1,3); %max_coord, max_value, state_max
    
    m1 = get_data002(filename, frame_start, coordname);
    [Rows,Columns] = size(m1);
    m_memory = zeros(Rows,Columns,fr_diff);
    m_memory(:,:,1) = m1;
    framestates(1, 6) = (frame_start + fr_diff)/30;

    for i = 1:fr_diff-2
        m_memory(:,:,i+1) = get_data002(filename, frame_start+i, coordname);
        t = (frame_start + fr_diff + i)/30; %%campionamento a 30 Hz
        framestates(i+1, 6) = t;
    end

    for i=fr_diff:Nframes

        %calcolo tempo
        t = (frame_start + fr_diff + i)/30; %%campionamento a 30 Hz
        framestates(i+1, 6) = t;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %salvataggio dati
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %update data
        m_memory(:,:,1:end-1) = m_memory(:,:,2:end);
        m_memory(:,:,end) = get_data002(filename, frame_start+i, coordname);

        mdiff = m_memory(:,:,end)-m_memory(:,:,1);
    end
end


