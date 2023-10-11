function [m1, mdiff] = get_data(filename, fr_evento, fr_diff, coordname)
    %seleziona area
    m1=readtable(sprintf(append(filename,'%d.CSV'),floor(10)),'Range','B9:XQ488');
    m1= m1{:,:};

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

    %salva dati
    for k = 1 : 2
        m1=readtable(sprintf(append(filename,'%d.CSV'), n),'Range','B9:XQ488'); %dimentions = (480x640)
        m1 = m1{:,:};

        %%%%%%%% store data %%%%%%%%%
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


    %Grafico
    %axdiff = axes(f,'outerPosition', [0.5 0 0.3 1]);
    m2 = frames{2, 1};
    m1 = frames{1, 1};
    mdiff = m2-m1;    
end

