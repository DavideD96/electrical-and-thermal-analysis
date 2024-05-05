function m = get_data002_matCoord(filename, fr_evento, coord, AvioFlir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-11 Last modification: 2023-10-11
%Author: Cristina Zuccali
%get_data(filename, fr_evento, fr_diff, coordname)
%
%Return the data of a frame in a wanted ragione and the difference of
%temperature value between fr_evento+fr_diff and fr_evento. this version
%does not load coordname, as get_data002. Uses coord instead. Filename must
%include the frame number.
%
%   'filename' = principal part of the file name of frame (including number of frame but no .CSV)
%   'fr_evento' = number of start frame
%   'fr_diff' = difference beetwen frame to show the difference of temperature
%   'coordname' = name of file with coordinates of the wanted region
%   'AvioFlir' = thermal camera producer (Avio = 0, Flir = 1).
%
%   'm1' = array of temperatures in the selected region of fr_evento
%   'mdiff' = array of temperatures variations in the selected region
%           between fr_evento+fr_diff and fr_evento
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %selection of the area
    x = coord(:,1);
    y = coord(:,2);

    y_bl = (round(y(3))-round(y(2)))+round(y(1));
    x_bl = round(x(3))-(round(x(2))-round(x(1)));

    %store data
    if AvioFlir == 0                                               % range di lettura per evitare l'intestazione
        m1=readtable(sprintf(append(filename,'%d.CSV'), fr_evento),'Range','B9:XQ488'); %dimentions = (480x640)
        m = m1{:,:};
    elseif AvioFlir == 1
        m1=readtable(sprintf(append(filename,'%d.csv'), fr_evento));%'Range','B9:XQ488');
        m = m1{:,:};
    end
    clear m1;

    ydim = size(m,1);
    xdim = size(m,2);

    if round(y(1)) >= round(y(2))
        boundaries = parallelogrammas_boundary2(ydim, 'l',[x(1),y(1)], 't',[x(2),y(2)], 'r',[x(3),y(3)], 'b',[x_bl,y_bl]); %left-top is the free egde of the CAF
    else
        boundaries = parallelogrammas_boundary2(ydim, 'l',[x_bl,y_bl], 't',[x(1),y(1)], 'r',[x(2),y(2)], 'b',[x(3),y(3)]);
    end

    y_ridotta = round(y_bl)-round(y(2));
    x_ridotta = round(x(3))-round(x(1));
    m1_ridotta = zeros(y_ridotta+1,x_ridotta+1); %+10



    n_pixel = 0;

    for i=1:ydim %righe    
        for j=1:xdim %colonne
            if j >= boundaries(i,1) && j <= boundaries(i,2)
                n_pixel = n_pixel + 1;
                m1_ridotta(i-round(y(2))+1,j-round(x(1))+1) = m(i,j); %+6
            end
        end
    end
    m = m1_ridotta;

end

