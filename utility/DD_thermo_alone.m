function DD_thermo_alone(filename, varargin)

num = length(varargin);
flip = false;
limCB = [];
set_area = 1;
frameRate = 20;
cd termoFiles_mat\
fr_diff = 1;
delay = 1;

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
    elseif prod(varargin{k}=='framediff')
        fr_diff = varargin{k+1};
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
m_all = load('mtotalT.mat','-mat');
m_all = cell2mat(struct2cell(m_all));


nFrames = size(m_all,3);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rallenty = 2;
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

    m1 = m_all(:,:,file);

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
f = figure;

for k = delay:size(m_all,3)

    axtemp = axes(f,'outerPosition', [0.175 0 0.31 1]);
    axdiff = axes(f,'outerPosition', [0.5 0 0.31 1]);

    m1 = m_all(:,:,floor(k));
    m2 = m_all(:,:,floor(k+fr_diff));

    if colormap_or_height == 0

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
            for kk = 1:size(m1,1)
                [T_max_aus(kk),ind_row(kk)] = max(abs(mdiff(kk,:)));
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

    title('Temperature [°C]','Parent',axtemp)
    title('Difference between frames [°C]','Parent',axdiff)
    annotation('textbox',[0.1 0.2 0.1 0.1],'String',num2str(k))

        frame = getframe(gcf);        % costruisco il
        writeVideo(vidObj, frame);    % filmato  puoi usare im2frame(m,cm) al posto di frame

        clf(f)
end

cd ..

        %delete(ann);
    
close(gcf);
close(vidObj);

clear S    %clear workspace

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


