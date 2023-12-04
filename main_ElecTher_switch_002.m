function main_ElecTher_switch_002(ElectrFilename, ThermalFilename, coordname, Nframes, frame_start, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-11-28
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
%Inizializzazione
%PARAMETRI DI DEFAULT
plot_TvsA = 1;

%varagin
num = length(varargin);
for k = 1:2:num
    if prod(varargin{k}=='plot_T_A')
        plot_TvsA = varargin{k+1}; %1 = confronta aree e temperature (sia per max che per min), 0 = non le confronta
    end
end

%controllo cartelle

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
El_sampl_fr = ElectrParameters.smplFr;

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
Th_sampl_fr = ThermalParameters.smplFr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electric %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if prod(analysis=='nll') %no analysis => detection only
    El_rs = mainSwitch(ElectrFilename, 'parameters', ElectMethod, 'col', column, 'nos', nsigma, 'nvt', 0);
else
    El_rs = mainSwitch(ElectrFilename, 'parameters', ElectMethod, 'col', column, 'nos', nsigma, 'nvt', 0, 'opt', analysis);
end

%El_rs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Thermal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Th_rs = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0); %aggiungi 'method', area method, detection method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Th_rs
%renormalize times
Th_rs(:,1) = Th_rs(:,1)-Th_rs(1,1);

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
plot([Th_rs(1,1),Th_rs(end,1)],1, '-');
hold on;
thRs = Th_rs(Th_rs(:,8)~=0,:);
gridxy(thRs(:,1), 'Color','k');
%plot(thRs(:,1),1, 'r*');
hold off;

% resistenza
% delta T
% area T

figure;

% cut electric array dimension to make it compatible with thermal
%El_rs = El_rs(1:end-fr_diff);

if Th_sampl_fr == 30 && El_sampl_fr == 20
    % thermal 30 Hz
    Th_rs_ = repelem(Th_rs,2,1);
    stop = size(Th_rs_,1);

    % electrical 20 Hz
    El_rs_ = repelem(El_rs.detection,3,1);
    El_rs_ = El_rs_(1:stop,:);
    
    period = 1/60;
    times = linspace(0,period*size(El_rs_,1),size(El_rs_,1));
    times = times';

elseif Th_sampl_fr == 10 && El_sampl_fr == 20
    % electrical 20 Hz
    El_rs_ = El_rs;
    stop = size(Eh_rs_,1);

    % thermal 10 Hz
    Th_rs_ = repelem(Th_rs,2,1);
    Th_rs_ = Th_rs_(1:stop,:);
    
    period = 1/20;
    times = linspace(0,period*size(El_rs_,1),size(El_rs_,1));
    times = times';

else
    disp('Incorrect frame rates.');
end
    
%line1: resistance
%line2: peak temperature
%line3: min temperature
%line4: area max
%line5: area min
    
resistance = El_rs_(:,end);
T_max = Th_rs_(:,4);
T_min = Th_rs_(:,5);
area_max = Th_rs_(:,6);
area_min = Th_rs_(:,7);

data = table(times, resistance,T_max,T_min,area_max,area_min);
data = renamevars(data,'times','times [s]');

data.Properties.VariableUnits = {'[s]','[\Omega]','[°C]','[°C]','[pixel #]','[pixel #]'};

degreeSymbol = char(176);
newYlabels = ["time [s]","R diff [Ohm]"," T max ["+ degreeSymbol + "C]","T min ["+ degreeSymbol + "C]","area max [pixel #]","area min [pixel #]"];
plt = stackedplot(data,'Title','Stacked Data','DisplayLabels',newYlabels, 'XVariable','times [s]');
grid on;
%pltax = plt.NodeChildren(end/2+1:end);
%for K = pltax.'; K.YLabel.Interpreter = 'tex'; end

%stackedplot(times,tabella_5);
%xlabel('time [s]');
%stackname = [filename,'_calibFr_', num2str(calibr_frame),'_stack5pixel_',num2str(pixel_away_from_CAF),'_frames_', num2str(Frames(1)),'-',num2str(Frames(2)),'.fig'];
%savefig(stacked,[path,stackname]); %'\'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot confronti %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
% str = append('T vs A (', ThermalFilename);
% str = append(str, ')');
sgtitle('T vs A')

subplot(3,1,1)
hold on
    plot(T_max(:,1), area_max(:,1), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    xlabel('Temperature difference [°C]');
    ylabel('Area [#pixels]');
    title('Positive events');
hold off

subplot(3,1,2)
hold on
    plot(T_min(:,1), area_min(:,1), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    xlabel('Temperature difference [°C]');
    ylabel('Area [#pixels]');
    title('"Negative events');
hold off

subplot(3,1,3)
T = [T_max(:,1); T_min(:,1)];
A = [area_max(:,1); -area_min(:,1)]; %area min negative per distinguerle dalle max
hold on
    plot(T(:,1), A(:,1), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    xlabel('Temperature difference [°C]');
    ylabel('Area [#pixels]');
    title('All events');
hold off

end