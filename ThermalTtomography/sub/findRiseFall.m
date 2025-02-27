function findRiseFall(frame1,frame2,varargin)

% this function asks to the user to identify an active site (hotspot). Then
% it shows the evolution of the temperature of the hotspot, and ask to
% indicate the initial increase and the final decrease in temperature (only 
% one pulse should have been applied!).
%
% frame1: frame to compute temperature difference, and thus, to identify
%         the conductive areas. For example a frame where the CAF is cold
%         (hot)
% frame2: frame to compute temperature difference, and thus, to identify
%         the conductive areas. For example a frame where the CAF is hot
%         (cold)
% varargin: frame duration of voltage application. if not specified, the
%           program asks to indicate both rise and fall frames. It's always
%           better to indicate this parameter, in order to reduce
%           uncertainty.
%
% This program saves:
% PULSE_startEnd.mat: array containing pulse start and end frames.


    num = length(varargin);
    cd termoFiles_mat\
    
    figure
    dat = load('mtotalT.mat');
    dat = dat.mtotalT;
    m1 = dat(:,:,frame1);
    m2 = dat(:,:,frame2);
    mdiff = m2-m1;

    if varargin{1} ~= 0 && num > 0
        imagesc(mdiff);
        colorbar
        title('select hotspot')
        pause
        [x,y] = ginput(1);
        x = round(x);
        y = round(y);
        figure
        temp = dat(y,x,:); %cambiato
        temp_aus1 = dat(y+3,x+3,:);
        temp_aus2 = dat(y-3,x-3,:);
    
        temp = squeeze(temp(1,1,:));
        temp_aus1 = squeeze(temp_aus1(1,1,:));
        temp_aus2 = squeeze(temp_aus2(1,1,:));
    
        plot(temp)
        hold on
        plot(temp_aus1)
        plot(temp_aus2)
        grid on
        hold off
    else
        x = 0;
        y = 0;
    end

    %plot(dat(x,y,frame1))


    if varargin{1} ~= 0 && num > 0
        if num > 0
            title('select start of application')
            pause
            application_frames = varargin{1};
            [t_startEnd,~] = ginput(1);
            t_startEnd = [t_startEnd; t_startEnd+application_frames];
        else
            title('select start-end of application')
            pause
            [t_startEnd,~] = ginput(2);
            application_frames = t_startEnd(2)-t_startEnd(1);
        end
    else
        t_startEnd = [0,0];
    end

    t_startEnd = round(t_startEnd);
    save('PULSE_startEnd.mat','t_startEnd','-mat')
    
    cd ..

    mean_ColdAndHot()%application_frames)

end
