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
    imagesc(mdiff);
    title('select hotspot')
    pause
    [x,y] = ginput(1);
    x = round(x);
    y = round(y);

    %plot(dat(x,y,frame1))
    figure
    temp = dat(x,y,:);
    temp = squeeze(temp(1,1,:));
    plot(temp)
    grid on
    
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

    t_startEnd = round(t_startEnd);
    save('PULSE_startEnd.mat','t_startEnd','-mat')
    
    cd ..

    mean_ColdAndHot(application_frames)

end
