function m = DD_read_thermocamera_singleFrameFLIR()


% script to read .CSV files from thermocamera -> array of struct/array of
% tables


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(gca, 'nextplot','replacechildren', 'Visible','off');

figure, set(gcf, 'Color','white')

load('ThermoColorMap1.mat');
set_area = 1;

if set_area == 1

    %%%%%%%%%%%%% use locate_CAF instead %%%%%%%%%%%%%
    %{
    colormap(cm);
    m=readtable(sprintf(append(filename,'%d.CSV'),floor(20)),'Range','B9:XQ488');
    m= m{:,:};
    imagesc(m);

    pause;
    [x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF
    %}

    m1=readtable('Rec A700 close-up-0002_229.csv','Range','B9:XQ488');
    m1 = m1{:,:}; %str2num(m{:,:})
    m1_ = zeros(size(m1,1),size(m1,2));

    m2=readtable('Rec A700 close-up-0002_230.csv','Range','B9:XQ488');
    m2 = m2{:,:}; %str2num(m{:,:})
    m2_ = zeros(size(m2,1),size(m2,2));

    for i = 1:size(m1_,1)
        for j = 1:size(m1_,2)
            m2_(i,j) = str2num(cell2mat(m2(i,j)));
            m1_(i,j) = str2num(cell2mat(m1(i,j)));
        end
    end

    % m1_ = m1_(100:200,100:200);
    % m2_ = m2_(100:200,100:200);
    %colormap(cm);
    %surf(m_ridotta);
    %zlim([zMin, zMax])
    surf(m2_-m1_)
    figure
    imagesc(m2_)
    %colorbar

    CAF_coord = load(coordname); %load(append(filename,'CAF_coordinates.mat'));
    x = CAF_coord.coordinates(:,1);
    y = CAF_coord.coordinates(:,2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    y_bl = (round(y(3))-round(y(2)))+round(y(1));
    x_bl = round(x(3))-(round(x(2))-round(x(1)));

    if round(y(1)) >= round(y(2))
        boundaries = parallelogrammas_boundary1(size(m,1), 'l',[x(1),y(1)], 't',[x(2),y(2)], 'r',[x(3),y(3)], 'b',[x_bl,y_bl]); %left-top is the free egde of the CAF
    else
        boundaries = parallelogrammas_boundary1(size(m,1), 'l',[x_bl,y_bl], 't',[x(1),y(1)], 'r',[x(2),y(2)], 'b',[x(3),y(3)]);
    end

    y_ridotta = round(y_bl)-round(y(2));
    x_ridotta = round(x(3))-round(x(1));
    m_ridotta = zeros(y_ridotta+10,x_ridotta+10);

    n_pixel = 0;

    if set_area == 1
        for i=1:480 %righe
            for j=1:640 %colonne
                if j >= boundaries(i,1) && j <= boundaries(i,2)
                    
                    n_pixel = n_pixel + 1;
                    m_ridotta(i-round(y(2))+6,j-round(x(1))+6) = m(i,j);
                end
            end
        end
    end
    
    T_max_aus = zeros(size(m_ridotta,2),1);
    ind_row = zeros(size(m_ridotta,2),1);

    for i = 1:size(m_ridotta,1)
        [T_max_aus(i),ind_row(i)] = max(m_ridotta(i,:));
    end
    [T_max,ind_col] = max(T_max_aus);

    figure;
    zMin = 25;
    zMax = 40;
    %clim([zMin, zMax]);
    colormap(cm);
    %surf(m_ridotta);
    %zlim([zMin, zMax])
    imagesc(m_ridotta, [zMin, zMax])
    colorbar
    title(['frame ',num2str(numFrame)])
    note = annotation('textbox',[.55 .93 .25 .07], ...
            'String',['T_{max} = ',num2str(T_max), ' (',num2str(ind_col),',',num2str(ind_row(ind_col)),')']);
    %axis equal
    hold off
else
    disp('ciao')
    m=readtable(sprintf(append(filename,'%d.CSV'),floor(numFrame)),'Range','B9:XQ488');
    m= m{:,:};

    %m7=readtable(sprintf(append(filename,'%d.CSV'),floor(numFrame)),'Range','B9:XQ488');
    %m7= m7{:,:};

    %m30=readtable(sprintf(append('E4_31_43_500umx2mm_em0_89_fr10_22_30_','%d.CSV'),floor(9)),'Range','B9:XQ488');
    %m30= m30{:,:};

    %mdiff = m30-m7;

    colormap(cm);
    %surf(m_ridotta);
    %zlim([zMin, zMax])
    imagesc(m)
    colorbar
    title(['frame ',num2str(numFrame)])
    %note = annotation('textbox',[.55 .93 .25 .07], ...
    %        'String',['T_{max} = ',num2str(T_max), ' (',num2str(ind_col),',',num2str(ind_row(ind_col)),')']);
    %axis equal
    hold off
    %figure
    %imagesc(mdiff)
    %colormap(cm);
    %colorbar
end
matr = m;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
