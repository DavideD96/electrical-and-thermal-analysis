function main_ElecTher_switch(ElectrFilename, ThermalFilename, coordname, Nframes, frame_start)
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

check = exist('ThEl_Results');
if check ~= 7
    mkdir('ThEl_Results');
end
%save the folder path where save data
path = [pwd,'\ThEl_Results\',];

cd 'parameters'
ThermalParameters_ = load('ThermalParameters.mat');
ElectrParameters_ = load('ElectricParameters.mat');
cd ..

ThermalParameters = ThermalParameters_.ThermalParameters;
ElectrParameters = ElectrParameters_.ElectrParameters; 
%%%%%%%%%%%%%%%%%%%%%%%%% electrical parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
%general
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
%Nframes = 'all';
soglia_max = ThermalParameters.soglia_max;
soglia_min = ThermalParameters.soglia_min;
detectMeth = ThermalParameters.detectMeth;
areaMeth = ThermalParameters.areaMeth;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electric %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if prod(analysis=='nll') %no analysis => detection only
    El_rs = mainSwitch(ElectrFilename, 'parameters', ElectMethod, MeasureType, 'col', column, 'nos', nsigma, 'nvt', nvt);
else
    El_rs = mainSwitch(ElectrFilename, 'parameters', ElectMethod, MeasureType, 'col', column, 'nos', nsigma, 'nvt', nvt, 'opt', analysis);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Thermal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,Th_rs] = analisi_Nframes(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0); %aggiungi 'method', area method, detection method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Th_rs
%renormalize times
Th_rs(:,6) = Th_rs(:,6)-Th_rs(1,6);

figure;
subplot(2,1,1);
title('electrical RS detection');
format long
%a = [El_rs.detection(:,end),El_rs.detection(:,end-2),El_rs.detection(:,end-1)]

plot([El_rs.detection(1,1),El_rs.detection(end-1,1)],1, '-');
hold on;
elRs = El_rs.detection(El_rs.detection(:,end-1)==1,:);
gridxy(elRs, 'Color','k');
%plot(elRs(:,1),1, 'r*');
hold off;

subplot(2,1,2);
title('thermal RS detection');
plot([Th_rs(1,6),Th_rs(end,6)],1, '-');
hold on;
thRs = Th_rs(Th_rs(:,5)==1,:);
gridxy(thRs(:,6), 'Color','k');
%plot(thRs(:,1),1, 'r*');
hold off;

%stackedplot(times,tabella_5);
%xlabel('time [s]');
%stackname = [filename,'_calibFr_', num2str(calibr_frame),'_stack5pixel_',num2str(pixel_away_from_CAF),'_frames_', num2str(Frames(1)),'-',num2str(Frames(2)),'.fig'];
% savefig(stacked,[path,stackname]); %'\'

end