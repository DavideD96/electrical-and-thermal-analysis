%generate two random series of events and compute STTC.

n_trials = 200;
npoints = 50; %interval segmentation
neventA = 2;
neventB = 25;
interval = 60; %[s]
freq = 50; %[Hz]
delta_t = [0.02,5]; %[s]
type = 'standard';%'bursting'; %

STTCs = zeros(npoints, n_trials+1);
STTCs(:,1) = linspace(delta_t(1),delta_t(2),npoints); %tempi

for i = 1:n_trials

    waitbar(i/n_trials)
    if prod(type == 'bursting')
        [gA,gB] = random_bursting_series_generator(neventA,neventB,interval,freq,3,0,0);
    elseif prod(type == 'standard')
        [gA,gB] = random_series_generator(neventA,neventB,interval,freq,0);
    end
    [result,n,n] = STTCmultiple_windows(gA,gB,delta_t,npoints,'plot_figure',0,'save_figure',0,'mat_or_work',1);
    STTCs(:,i+1) = result(:,2);
    % if 0.6>(result(end,2))
    %     STTC_001(gA,gB,19.5,'displ_debug',1,'mat_or_work',1)
    %     %return
    % end
end

disp(STTCs(:,2:end))

STTC_mean_std = STTCs(:,1);
STTC_mean_std(:,2) = mean(STTCs(:,2:end),2);

STTC_mean_std(:,3) = std(STTCs(:,2:end),0,2);

a = figure;
p = plot(STTC_mean_std(:,1),STTC_mean_std(:,2),'k');
hold on
grid on
plot(STTC_mean_std(:,1),STTC_mean_std(:,2)-2*STTC_mean_std(:,3),'k--')
plot(STTC_mean_std(:,1),STTC_mean_std(:,2)+2*STTC_mean_std(:,3),'k--')
title(append(type,'.  Mean STTC nevents: ',num2str(neventA),', ',num2str(neventB)))
legend([p(1)],[num2str(neventA),' ',num2str(neventB)])
xlabel('\Deltat [s]')
hold off
saveas(a,append(type,' ',num2str(neventA),' ',num2str(neventB),'.png'),'png'); %num2str(neventA),' vs ',num2str(neventB),'events.png'),'png');
