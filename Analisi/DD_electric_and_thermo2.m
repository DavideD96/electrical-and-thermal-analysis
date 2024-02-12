function DD_electric_and_thermo2(filename, varargin)

num = length(varargin);

for k = 1:2:num
    if prod(varargin{k}=='graphType')
        colormap_or_height = varargin{k+1};
    elseif prod(varargin{k}=='coordname')
        coordname = varargin{k+1};
    elseif prod(varargin{k}=='makeVideo')
        video = varargin{k+1};
    elseif prod(varargin{k}=='frameRtRs')
        frameRate = varargin{k+1};
    elseif prod(varargin{k}=='numFrames')
        Frames = varargin{k+1};
    elseif prod(varargin{k}=='setSurfce')
        set_area = varargin{k+1};
    elseif prod(varargin{k}=='direction')
        direction = varargin{k+1};
    elseif prod(varargin{k}=='resistDat')
        Rname = varargin{k+1};
    elseif prod(varargin{k}=='initDelay')
        delay = varargin{k+1};
    end
end


% script to read .CSV files from thermocamera -> array of struct/array of
% tables

%%%%%%%%%%%%%%%%%%%%%%%%% additional inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%colormap_or_height = 1;
%set_area = 1;
save_ = false;
calib_modulus = 15;
mean_obj = 1;
data_for_fit = true;
frames_for_data = [20 30];
%%%% heat diffusion away from CAF %%%%
pixel_away_from_CAF = 30; %cioè 1 mm (?)
%direction = 'dw'; %evita di andare nella direzione delle piste
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% heat diffusion along the CAF %%%%
pixel_inside_electrode = 20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nFrames = Frames(2)-Frames(1)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check = exist(['ThermoResults\',filename]);
if check ~= 7
    mkdir(['ThermoResults\',filename]);
end
%save the folder path where save data
path = [pwd,'\ThermoResults\',filename,'\',];

set(gca, 'nextplot','replacechildren', 'Visible','off');

figure, set(gcf, 'Color','white')

load('ThermoColorMap1.mat');


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

    m1=readtable(sprintf(append(filename,'%d.CSV'),floor(10)),'Range','B9:XQ488');
    m1= m1{:,:};

    CAF_coord = load(coordname); %load(append(filename,'CAF_coordinates.mat'));
    x = CAF_coord.coordinates(:,1);
    y = CAF_coord.coordinates(:,2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    y_bl = (round(y(3))-round(y(2)))+round(y(1));
    x_bl = round(x(3))-(round(x(2))-round(x(1)));

    if round(y(1)) >= round(y(2))
        boundaries = parallelogrammas_boundary1(size(m1,1), 'l',[x(1),y(1)], 't',[x(2),y(2)], 'r',[x(3),y(3)], 'b',[x_bl,y_bl]); %left-top is the free egde of the CAF
    else
        boundaries = parallelogrammas_boundary1(size(m1,1), 'l',[x_bl,y_bl], 't',[x(1),y(1)], 'r',[x(2),y(2)], 'b',[x(3),y(3)]);
    end

    y_ridotta = round(y_bl)-round(y(2));
    x_ridotta = round(x(3))-round(x(1));
    m1_ridotta = zeros(y_ridotta+10,x_ridotta+10);

end

%%%%%%%% check for calibration (1 admitted!!!) %%%%%%%%%%
calibr_frame = 0;

% primo frame a parte
m1=readtable(sprintf(append(filename,'%d.CSV'),1),'Range','B9:XQ488'); %dimentions = (480x640)
m1= m1{:,:};
control_old = [m1(3,3),m1(3,637);m1(477,3),m1(477,637)];

control_matrix = [calib_modulus/frameRate,calib_modulus/frameRate,;calib_modulus/frameRate,calib_modulus/frameRate]; %arbitrario -.-"

Tmax = 0;
Tmin = 500; %usato sempre il range 0-500 °C

frames = cell(nFrames,1);
frames_tot = cell(nFrames,1);

for file=1:nFrames
    m1 = readtable(sprintf(append(filename,'%d.CSV'),file),'Range','B9:XQ488'); %dimentions = (480x640)
    m1 = m1{:,:};

    control_new = [m1(3,3),m1(3,637);m1(477,3),m1(477,637)];
    if all(abs(control_new-control_old) > control_matrix)
        calibr_frame = file;
        deltaT_calib = control_new(1,1)-control_old(1,1);
        %Tmax = max(m); %prima misura precisa di temperatura massima (calibrazione appena avvenuta)
        %Tmin = min(m); %rima misura precisa di temperatura minima (calibrazione appena avvenuta)
        disp(['WARNING: CALIBRATION HAPPENS!!! at frame: ', num2str(file)]);
    end
    control_old = control_new;

    %%%%%%%% store data %%%%%%%%%
    n_pixel = 0;

    if set_area == 1
        for i=1:480 %righe
            for j=1:640 %colonne
                if j >= boundaries(i,1) && j <= boundaries(i,2)
                    
                    n_pixel = n_pixel + 1;
                    m1_ridotta(i-round(y(2))+6,j-round(x(1))+6) = m1(i,j);
                end
            end
        end
        
        frames(file,1) = {m1_ridotta};
    else
        frames(file,1) = {m1};
    end

    frames_tot(file,1) = {m1};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rallenty = 4;
video = 1;
colormap_or_height = 0;
%# create AVI object
if video == 1
    if set_area == 1
        video_name = strcat(filename,'_onlyCAF_');
    elseif set_area == 0
        video_name = strcat(filename,'_allSubstr_');
    end

    video_name = [video_name,'_-RT-_calibFr_',num2str(calibr_frame),'_'];

    if colormap_or_height == 1
        video_name = strcat(video_name,'surface.avi');
    elseif colormap_or_height == 0
        video_name = strcat(video_name,'color.avi');
    end

    vidObj = VideoWriter(append(path,video_name));
    vidObj.Quality = 100; % max (credo)
    vidObj.FrameRate = frameRate/rallenty;
    open(vidObj);

end

%%%%%%%%%%%%%%% statistic section and %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% find max-min temperature %%%%%%%%%%%%%%%%%

max_Temp_array = zeros(nFrames,1);
mean_Temp_array = zeros(nFrames,1);
std_Temp_array = zeros(nFrames,1);

% ATTENZIONE! LA SEGUENTE ORIENTAZIONE NON è AMMESSA
%             *
%  * ELECTRODE *
%   *           *
%    *     *  *
%     *  * CAF *
%         *     *  *
%          *  *     *
%        *           *
%         * ELECTRODE *
%          * 

for file=1:nFrames

    m1 = frames{file,1};
    m_tot = frames_tot{file,1};

    %if set_area == 1
    %   m = m(round(y(2)):round(y_bl),round(x(1)):round(x(3)));

    %end

    if file < calibr_frame
        m1(m1>0) = m1(m1>0) + deltaT_calib;
        m_tot = m_tot + deltaT_calib;

        frames(file,1) = {m1};
        frames_tot(file,1) = {m_tot};
    end
 
    if set_area == 1
        Tactual_max = max(max(m1));
        Tactual_min = min(min(m1(m1>0))); %non zero minimum
        mean_Temp_array(file,1) = sum(sum(m1))/n_pixel;

        %compute std
        m_ = m1;
        m_(m_>0) = m_(m_>0)-mean_Temp_array(file,1);
        m_ = m_.^2;
        std_Temp_array(file,1) = sqrt(sum(m_,'all')/(n_pixel-1));

    else
        Tactual_max = max(max(m_tot));
        Tactual_min = min(min(m_tot(m_tot>0))); %non zero minimum
        mean_Temp_array(file,1) = sum(sum(m_tot))/(480*640);
    end
    max_Temp_array(file,1) = Tactual_max;

    if Tactual_max > Tmax
        Tmax = Tactual_max;
    end

    if Tactual_min < Tmin
        Tmin = Tactual_min;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
%figure('Renderer', 'painters', 'Position', [10 10 900 600])

%%%%%%%%%%%%%%%%%%%%% video section %%%%%%%%%%%%%%%%%%%%%
R_ = load(Rname);
Res = R_.R;
Res(:,1) = Res(:,1)-Res(1,1);
nres = size(Res,1);
termo_times = zeros(nFrames,1);
termo_fr_over_res_fr = 1.5; %0.5;

for i=1:nFrames
    termo_times(i)=(i-1)*1/(termo_fr_over_res_fr*frameRate);
end

if termo_fr_over_res_fr > 1
    video_length = nFrames*2; %considero solo caso a 30 Hz, per cui se campiono resistenza a 20 Hz => 60 Hz
    video_frameRate = 60;
else
    video_length = nres;
    video_frameRate = 20;
end

video_times = zeros(video_length,1);

for i=1:video_length
    video_times(i) = (i-1)*1/video_frameRate;
end

dist_da_prec = 1;
dist_da_succ = 1;
f = figure('position',[200 100 1000 500]);

axres = axes(f,'outerPosition', [0 0 0.3 1]); %subplot(1,3,1);
axtemp = axes(f,'outerPosition', [0.35 0 0.3 1]);
axdiff = axes(f,'outerPosition', [0.7 0 0.3 1]);

termo_time_index = 1;
count = 1;

for i=1:delay*2

    m1 = frames{floor(termo_time_index),1};
    m2 = frames{floor(termo_time_index+1),1};

    if colormap_or_height == 0

        imagesc(m1, 'Parent',axtemp);
        colormap(cm);
        clim(axtemp,[Tmin Tmax]);
        colorbar(axtemp);
        title(filename, 'Interpreter','none','Parent',axtemp);
        xlabel('[n° pixel]','Parent',axtemp);
        ylabel('[n° pixel]','Parent',axtemp);

        T_max_aus = zeros(size(m1,2),1);
        ind_row = zeros(size(m1,2),1);

        mdiff = m2-m1;
        for k = 1:size(m1,1)
            [T_max_aus(k),ind_row(k)] = max(abs(mdiff(k,:)));
        end
        [T_max,ind_col] = max(T_max_aus);

        zMin = -T_max;
        zMax = T_max;
        %clim([zMin, zMax]);
        
        %surf(m_ridotta);
        %zlim([zMin, zMax])
        imagesc(mdiff,'Parent',axdiff);
        colormap(cm);
        clim(axdiff,[zMin, zMax]);
        colorbar(axdiff);
        xlabel('[n° pixel]','Parent',axdiff);
        ylabel('[n° pixel]','Parent',axdiff);

    else
        surf(flip(m1));
        zlim([Tmin Tmax]);
        zlabel('Temperature [°C]','Parent',axtemp);
        xlabel('[n° pixel]','Parent',axtemp);
        ylabel('[n° pixel]','Parent',axtemp);
        title(filename, 'Interpreter','none','Parent',axtemp);
    end

    for j=1:termo_fr_over_res_fr+0.5 %%% cafone, serve a fare 2 frame uguali in successione
        frame = getframe(gcf);        % costruisco il
        writeVideo(vidObj, frame);    % filmato  puoi usare im2frame(m,cm) al posto di frame
    end
    termo_time_index = termo_time_index+0.5;
end

disp(termo_time_index);
res_time_index = 1;

for k=termo_time_index:video_length %Cafone, funziona a 30 Hz, cambia


    % 
    % if Res(res_index,1)-video_times(i) < 0 %allora .  x  .     .
    %     if video_times(i)-Res(res_index,1) > Res(res_index,1)-video_times(i-1) %allora . x   .     .
    %         %video_times(i) in fase con Res(i,1)
    % 
    %     end
    % else %allora .    .  x  .
    %     if video_times(i)-Res(res_index,1) < Res(res_index,1)-video_times(i+1) %allora .     .   x .
    % 
    %     end
    % end

    if termo_time_index<=nFrames
        %disp('ciao')
       
        m1 = frames{floor(termo_time_index),1};

        if termo_time_index < nFrames
            m2 = frames{floor(termo_time_index+2),1}; %cafone
        else
            m2 = frames{floor(termo_time_index),1};
        end
    
        if colormap_or_height == 0
    
            imagesc(m1, 'Parent',axtemp);
    
            colormap(cm);
            clim(axtemp,[Tmin Tmax]);
            colorbar(axtemp);
            xlabel('[n° pixel]','Parent',axtemp);
            ylabel('[n° pixel]','Parent',axtemp);
            title('Temperature [°C]', 'Interpreter','none','Parent',axtemp);

            T_max_aus = zeros(size(m1,2),1);
            ind_row = zeros(size(m1,2),1);

            mdiff = m2 - m1;
            for j = 1:size(m1,1)
                [T_max_aus(j),ind_row(j)] = max(abs(mdiff(j,:)));
            end
            [T_max,ind_col] = max(T_max_aus);

            zMin = -T_max;
            zMax = T_max;
            %clim([zMin, zMax]);
            
            colormap(cm);
            %surf(m_ridotta);
            %zlim([zMin, zMax])
            imagesc(mdiff,'Parent',axdiff)
            clim(axdiff,[zMin, zMax]);
            colorbar(axdiff);
            xlabel('[n° pixel]','Parent',axdiff);
            ylabel('[n° pixel]','Parent',axdiff);
    
        else
            surf(flip(m1));
            zlim([Tmin Tmax]);
            zlabel('Temperature [°C]','Parent',axtemp);
            xlabel('[n° pixel]','Parent',axtemp);
            ylabel('[n° pixel]','Parent',axtemp);
    
            title(filename, 'Interpreter','none','Parent',axtemp);
        end
    

        ann = annotation('textbox',...
        [0.65 0.1 0.05 0.05],'String',num2str(floor(termo_time_index)));
        xlabel('time [s]', 'Parent',axres); 
        ylabel('resistance [\Omega]','Parent',axres);
        if res_time_index <= 30
            plot(Res(1:60,1), Res(1:60,end),'Parent',axres);
            xlim(axres,[Res(1,1),Res(60,1)])
        elseif res_time_index+30 >= size(Res,1)
            plot(Res(end-60:end,1), Res(end-60:end,end),'Parent',axres);
            xlim(axres,[Res(nres-60,1),Res(nres,1)])
        else
            plot(Res(res_time_index-30:res_time_index+30,1), Res(res_time_index-30:res_time_index+30,end),'Parent',axres);
            xlim(axres,[Res(res_time_index-30,1),Res(res_time_index+30,1)])
        end
        xline(axres, Res(res_time_index,1),'-');
        grid(axres, "on");
        dist_da_prec = Res(res_time_index,1) - termo_times(floor(termo_time_index-delay));
        dist_da_succ = Res(res_time_index+1,1) - termo_times(floor(termo_time_index-delay));
        termo_time_index = termo_time_index+0.5;

        if dist_da_succ*dist_da_prec <= 0
            %disp('cambio')
            res_time_index = res_time_index + 1;
        else
            %disp('non cambio')
        end
    else
        termo_time_index = termo_time_index + termo_fr_over_res_fr;
    end    
        frame = getframe(gcf);        % costruisco il
        writeVideo(vidObj, frame);    % filmato  puoi usare im2frame(m,cm) al posto di frame
        delete(ann);
end
    
close(gcf);
close(vidObj);

clear S    %clear workspace

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


