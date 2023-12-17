function [m1, mdiff] = get_data(filename, fr_evento, fr_diff, coordname)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-11 Last modification: 2023-10-11
%Author: Cristina Zuccali
%get_data(filename, fr_evento, fr_diff, coordname)
%
%Return the data of a frame in a wanted ragione and the difference of
%temperature value between fr_evento+fr_diff and fr_evento.
%
%   'filename' = principal part of the file name of frame (without number of frame and .CSV)
%   'fr_evento' = number of start frame
%   'fr_diff' = difference beetwen frame to show the difference of temperature
%   'coordname' = name of file with coordinates of the wanted region
%
%   'm1' = array of temperatures in the selected region of fr_evento
%   'mdiff' = array of temperatures variations in the selected region
%           between fr_evento+fr_diff and fr_evento
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %selection of the area
    CAF_coord = load(coordname);
    x = CAF_coord.coordinates(:,1);
    y = CAF_coord.coordinates(:,2);

    y_bl = (round(y(3))-round(y(2)))+round(y(1));
    x_bl = round(x(3))-(round(x(2))-round(x(1)));

    if round(y(1)) >= round(y(2))
        boundaries = parallelogrammas_boundary2(480, 'l',[x(1),y(1)], 't',[x(2),y(2)], 'r',[x(3),y(3)], 'b',[x_bl,y_bl]); %left-top is the free egde of the CAF
    else
        boundaries = parallelogrammas_boundary2(480, 'l',[x_bl,y_bl], 't',[x(1),y(1)], 'r',[x(2),y(2)], 'b',[x(3),y(3)]);
    end

    y_ridotta = round(y_bl)-round(y(2));
    x_ridotta = round(x(3))-round(x(1));
    m1_ridotta = zeros(y_ridotta+10,x_ridotta+10);
        n = fr_evento;

    %store data
    for k = 1 : 2
        m1=readtable(sprintf(append(filename,'%d.CSV'), n),'Range','B9:XQ488'); %dimentions = (480x640)
        m1 = m1{:,:};

        n_pixel = 0;

        for i=1:480 %righe    
            for j=1:640 %colonne
                if j >= boundaries(i,1) && j <= boundaries(i,2)
                    n_pixel = n_pixel + 1;

                    m1_ridotta(i-round(y(2))+6,j-round(x(1))+6) = m1(i,j);
                end
            end
        end
        frames(k,1) = {m1_ridotta};
        n = fr_evento + fr_diff;
    end

    %Graph
    m2 = frames{2, 1};
    m1 = frames{1, 1};
    mdiff = m2-m1;
    
end

