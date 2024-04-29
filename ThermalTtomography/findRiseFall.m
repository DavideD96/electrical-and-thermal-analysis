function findRiseFall(frame1,frame2)

% this function asks to the user to identify an active site (hotspot). Then
% it shows the evolution of the temperature of the hotspot, and ask to
% indicate the initial increase and the final decrease in temperature (only 
% one pulse should have been applied!).
%

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
    pause
    [t_startEnd,~] = ginput(2)
    save('PULSE_startEnd.mat','t_startEnd','-mat')
    
    cd ..

end
