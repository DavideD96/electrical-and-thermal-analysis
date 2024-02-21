function DD_electric_and_thermo3(filename, varargin)

num = length(varargin);
flip = false;
limCB = [];
set_area = 1;
frameRate = 20;
Rname = 'Data.mat';

for k = 1:2:num
    if prod(varargin{k}=='graphType')
        colormap_or_height = varargin{k+1};
    elseif prod(varargin{k}=='makeVideo')
        video = varargin{k+1};
    elseif prod(varargin{k}=='frameRtRs')
        frameRate = varargin{k+1};
    elseif prod(varargin{k}=='numFrames')
        Frames = varargin{k+1};
    elseif prod(varargin{k}=='setCBlimt')
        limCB = varargin{k+1};
    elseif prod(varargin{k}=='setSurfce')
        set_area = varargin{k+1};
    elseif prod(varargin{k}=='direction')
        direction = varargin{k+1};
    elseif prod(varargin{k}=='resistDat')
        Rname = varargin{k+1};
    elseif prod(varargin{k}=='initDelay')
        delay = varargin{k+1};
    elseif prod(varargin{k}=='flipimage')
        flip = varargin{k+1};
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

%%%%%%%% check for calibration (1 admitted!!!) %%%%%%%%%%
calibr_frame = 0;

% primo frame a parte
Tmax = 0;
Tmin = 500; %usato sempre il range 0-500 °C

m_all = load('mtotalT.mat','-mat');
frames = cell2mat(struct2cell(m_all));

if flip == true
    frames = permute(conj(frames),[2,1,3]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rallenty = 1;
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

    m1 = frames(:,:,file);

    %if set_area == 1
    %   m = m(round(y(2)):round(y_bl),round(x(1)):round(x(3)));

    %end
 
    Tactual_max = max(max(m1));
    Tactual_min = min(min(m1)); %non zero minimum

    max_Temp_array(file,1) = Tactual_max;

    if Tactual_max > Tmax
        Tmax = Tactual_max;
    end

    if Tactual_min < Tmin
        Tmin = Tactual_min;
    end
end

% Tmin = 21;
% Tmax = 28;
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
    termo_times(i)=(i-1)*1/(termo_fr_over_res_fr*frameRate-0.2);
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

axres = axes(f,'outerPosition', [0.05 0 0.31 1]); %subplot(1,3,1);
axtemp = axes(f,'outerPosition', [0.375 0 0.31 1]);
axdiff = axes(f,'outerPosition', [0.7 0 0.31 1]);


termo_time_index = 1;
count = 1;

start_video = 30;

for i=1:delay*2

    m1 = frames(:,:,floor(termo_time_index));
    m2 = frames(:,:,floor(termo_time_index+1));

    if colormap_or_height == 0

        xlabel('time [s]', 'Parent',axres); 
        ylabel('resistance [\Omega]','Parent',axres);

        imagesc(m2, 'Parent',axtemp);
        colormap(cm);
        clim(axtemp,[Tmin Tmax]);
        colorbar(axtemp);
        %title(filename, 'Interpreter','none','Parent',axtemp);
        xlabel('[n° pixel]','Parent',axtemp);
        ylabel('[n° pixel]','Parent',axtemp);
        hold off

        T_max_aus = zeros(size(m1,2),1);
        ind_row = zeros(size(m1,2),1);

        mdiff = m2-m1;

        if size(limCB,1) == 0 
            for k = 1:size(m1,1)
                [T_max_aus(k),ind_row(k)] = max(abs(mdiff(k,:)));
            end
            [T_max,ind_col] = max(T_max_aus);
        
            zMin = -T_max;
            zMax = T_max;
        else
            zMin = limCB(1);
            zMax = limCB(2);
        end
        %clim([zMin, zMax]);
        
        %surf(m_ridotta);
        %zlim([zMin, zMax])
        imagesc(mdiff,'Parent',axdiff);
        colormap(cm);
        clim(axdiff,[zMin, zMax]);
        colorbar(axdiff);
        xlabel('[n° pixel]','Parent',axdiff);
        ylabel('[n° pixel]','Parent',axdiff);
        hold off

    else
        surf(flip(m1));
        zlim([Tmin Tmax]);
        zlabel('Temperature [°C]','Parent',axtemp);
        xlabel('[n° pixel]','Parent',axtemp);
        ylabel('[n° pixel]','Parent',axtemp);
        %title(filename, 'Interpreter','none','Parent',axtemp);
    end

    title('Electrical resistance [\Omega]','Parent',axres)
    title('Temperature [°C]','Parent',axtemp)
    title('Difference between consecutive frames [°C]','Parent',axdiff)

    for j=1:termo_fr_over_res_fr+0.5 %%% cafone, serve a fare 2 frame uguali in successione
        
        if i >= start_video
            frame = getframe(gcf);        % costruisco il
            writeVideo(vidObj, frame);    % filmato  puoi usare im2frame(m,cm) al posto di frame
        end
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
        %termo_time_index
       
        m1 = frames(:,:,floor(termo_time_index));

        if termo_time_index < nFrames
            m2 = frames(:,:,floor(termo_time_index+1)); %perche era +2??? %cafone
        else
            m2 = frames(:,:,floor(termo_time_index));
        end
    
        if colormap_or_height == 0
    
            imagesc(m2, 'Parent',axtemp);
    
            colormap(cm);
            clim(axtemp,[Tmin Tmax]);
            colorbar(axtemp);
            xlabel('[n° pixel]','Parent',axtemp);
            ylabel('[n° pixel]','Parent',axtemp);
            %title('Temperature [°C]', 'Interpreter','none','Parent',axtemp);

            hold off;

            T_max_aus = zeros(size(m1,2),1);
            ind_row = zeros(size(m1,2),1);

            mdiff = m2 - m1;

            if size(limCB,1) == 0
                for j = 1:size(m1,1)
                    [T_max_aus(j),ind_row(j)] = max(abs(mdiff(j,:)));
                end
                [T_max,ind_col] = max(T_max_aus);

                zMin = -T_max;
                zMax = T_max;
            else
                zMin = limCB(1);
                zMax = limCB(2);
            end


            %clim([zMin, zMax]);
            
            colormap(cm);
            %surf(m_ridotta);
            %zlim([zMin, zMax])
            imagesc(mdiff,'Parent',axdiff)
            clim(axdiff,[zMin, zMax]);
            colorbar(axdiff);
            xlabel('[n° pixel]','Parent',axdiff);
            ylabel('[n° pixel]','Parent',axdiff);
            hold off;
    
        else
            surf(flip(m1));
            zlim([Tmin Tmax]);
            zlabel('Temperature [°C]','Parent',axtemp);
            xlabel('[n° pixel]','Parent',axtemp);
            ylabel('[n° pixel]','Parent',axtemp);
            hold off
    
            %title(filename, 'Interpreter','none','Parent',axtemp);
        end
    

        % ann = annotation('textbox',...
        % [0.65 0.1 0.05 0.05],'String',num2str(floor(termo_time_index)));

        if res_time_index <= 30
            plot(Res(1:60,1), Res(1:60,end),'Parent',axres, 'LineWidth',2);
            xlim(axres,[Res(1,1),Res(60,1)])
        elseif res_time_index+30 >= size(Res,1)
            plot(Res(end-60:end,1), Res(end-60:end,end),'Parent',axres, 'LineWidth',2);
            xlim(axres,[Res(nres-60,1),Res(nres,1)])
        else
            plot(Res(res_time_index-30:res_time_index+30,1), Res(res_time_index-30:res_time_index+30,end),'Parent',axres, 'LineWidth',2);
            xlim(axres,[Res(res_time_index-30,1),Res(res_time_index+30,1)])
        end
        xline(axres, Res(res_time_index,1),'-', 'LineWidth',2);
        grid(axres, "on");
        hold off

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

    xlabel('time [s]', 'Parent',axres); 
    ylabel('resistance [\Omega]','Parent',axres);
    title('Electrical resistance [\Omega]','Parent',axres)
    title('Temperature [°C]','Parent',axtemp)
    title('Difference between consecutive frames [°C]','Parent',axdiff)

        frame = getframe(gcf);        % costruisco il
        writeVideo(vidObj, frame);    % filmato  puoi usare im2frame(m,cm) al posto di frame
        %delete(ann);
end
    
close(gcf);
close(vidObj);

clear S    %clear workspace

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


