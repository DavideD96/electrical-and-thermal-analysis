function main_ElecTher_switch(ElectrFilename, ElectrParameters, ThermalFilename, ThermalParameters, coordname, Nframes, frame_start)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-10-16
%Authors: Cristina Zuccali, Davide Decastri
%main_ElecTher_switch(ElectrFilename, ElectrParameters, ThermalFilename, ThermalParameters, coordname, Nframes, frame_start)
%
%Performs RS detection on both IR images and electic data. 
%
%   'ElectrFilename' = name of the file containing electrical measurements
%   'ElectrParameters' = structure containing parameters for electrical RS tracking (see mainSwitch help)
%   'ThermalFilename' = principal part of the file name of frame (without number of frame and .CSV)
%   'ThermalParameters' = structure containing parameters for electrical RS tracking (see analisi_Nframes help)
%   'coordname' = name of file with coordinates of the wanted region
%   'Nframes' = number of frames to be analysed.
%   'frame_start' = frame corresponding to electrical measumerement start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%% electrical parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

%general
filename = ElectrParameters.filename;
ElectMethod = ElectrParameters.method;
MeasureType = ElectrParameters.measType;
column = ElectrParameters.column; % 4 = resistance
nsigma = ElectrParameters.nsigma;

%analysis
nvt = ElectrParameters.nvt; %noise interval
analysis = ElectrParameters.analysis;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% thermal parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%global
fr_diff = ThermalParameters.fr_diff;
Nframes = 'all';
soglia_max = ThermalParameters.soglia_max;
soglia_min = ThermalParameters.soglia_min;
detectMeth = ThermalParameters.detectMeth;
areaMeth = ThermalParameters.areaMeth;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electric %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if prod(analysis=='nll') %no analysis => detection only
    El_rs = mainSwitch(ElectrFilename, folder, ElectMethod, 'col', column, 'nos', nsigma, 'nvt', nvt);
else
    El_rs = mainSwitch(ElectrFilename, folder, ElectMethod, 'col', column, 'nos', nsigma, 'nvt', nvt, 'opt', analysis);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Thermal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Th_rs = analisi_Nframes(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'method', areaMeth, 'makeVideo',0,'smoothing',0); %aggiungin detection method

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
subplot(2,1,1);
title('electrical RS detection');
plot([El_rs.detection(1,1),El_rs.detection(end,1)],1, '-');
hold on;
elRs = El_rs.detection(El_rs.detection(:,end)==1,:);
gridxy(elRs, 'Color','k');
plot(elRs(:,1),1, 'r*');
hold off;

subplot(2,1,2);
title('thermal RS detection');
plot([anlR(1,1),anlR(end,1)],1, '-');
hold on;
gridxy(random_anlR(:,1), 'Color','k');
plot(random_anlR(:,1),1, 'r*');
hold off;


% stackedplot(times,tabella_5);
% xlabel('time [s]');
% stackname = [filename,'_calibFr_', num2str(calibr_frame),'_stack5pixel_',num2str(pixel_away_from_CAF),'_frames_', num2str(Frames(1)),'-',num2str(Frames(2)),'.fig'];
% savefig(stacked,[path,stackname]); %'\'

end