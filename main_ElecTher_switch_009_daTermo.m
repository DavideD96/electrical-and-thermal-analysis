function main_ElecTher_switch_009_daTermo(ElectrFilename, frame_start, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-12-11
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
%
%   'Eventi_Termo_principali' = (Nframe x 8) array containing: time, max location,
%                               max temperature, min location, min temperature, 
%                               max area, min area, event number.
%   'Eventi_Termo_principali_doppi' = (2*Nframe x 8) array. Same as 'Eventi_Termo_principali'
%                                      duplicated.
%   'resistance_switch' = [delta conductance, event]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inizializzazione
%PARAMETRI DI DEFAULT
plot_TvsA = 1;
plot_RvsT = 1;
trace_peaks = 1;
couple_comparison = 0;
selectInt = false;

%varagin
num = length(varargin);
for k = 1:2:num
    if prod(varargin{k} =='plot_TvsA')
        plot_TvsA = varargin{k+1}; %1 = confronta aree e temperature (sia per max che per min), 0 = non le confronta
    elseif prod(varargin{k} == 'plot_RvsT')
        plot_RvsT = varargin{k+1};
    elseif prod(varargin{k} == 'tra_peaks')
        trace_peaks = varargin{k+1};
    elseif prod(varargin{k} == 'comp_coup')
        couple_comparison = varargin{k+1}; %1 = confronta le posizione delle coppie max-min, 0 = non le confronta
    elseif prod(varargin{k} == 'PowerCons')
        power_consideration = varargin{k+1}; %1 = confronta le posizione delle coppie max-min, 0 = non le confronta
    elseif prod(varargin{k} == 'First_Run')
        selectInt = varargin{k+1};   
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
Rows = ThermalParameters.Rows;
Columns = ThermalParameters.Columns;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electric %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if prod(analysis=='nll') %no analysis => detection only
    El_rs = mainSwitch(ElectrFilename, 'parameters', ElectMethod, 'col', column, 'nos', nsigma, 'nvt', selectInt, 'RoG',1);
else
    El_rs = mainSwitch(ElectrFilename, 'parameters', ElectMethod, 'col', column, 'nos', nsigma, 'nvt', selectInt, 'opt', analysis);
end

%El_rs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Thermal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[Th_rs, Rows, Columns] = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0, 'PowerCons', power_consideration); %aggiungi 'method', area method, detection method
[Th_rs, Eventi_Termo] = analisi_Nframes011_multiEvento_007_NOpV(frame_start, 'makeVideo', 0);
%size(Th_rs)
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
    stop_t = size(Th_rs_,1);

    % electrical 20 Hz
    El_rs_ = repelem(El_rs.detection,3,1);
    stop_rs = size(El_rs_, 1);
    stop = min(stop_t, stop_rs);

    El_rs_ = El_rs_(1:stop,:);
    Th_rs_ = Th_rs_(1:stop,:);
    
    period = 1/60;
    times = linspace(0,period*size(El_rs_,1),size(El_rs_,1));
    times = times';

elseif Th_sampl_fr == 10 && El_sampl_fr == 20
    % electrical 20 Hz
    El_rs_ = El_rs;
    stop = size(El_rs.detection,1);

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

DeltaConduct = El_rs_(:,end);
resistance_events = [DeltaConduct, El_rs_(:, end-1)]; %[event number, Delta resistance]
size(DeltaConduct);
size(Th_rs_);

save("resistance_switch.mat", "resistance_events")
save("Eventi_Termo_principali_doppi.mat", "Th_rs_")
save("Eventi_Termo_principali.mat", "Th_rs")
T_max = Th_rs_(:,4);
T_min = Th_rs_(:,5);
area_max = Th_rs_(:,6);
area_min = Th_rs_(:,7);

data = table(times, DeltaConduct,T_max,T_min,area_max,area_min);
data = renamevars(data,'times','times [s]');

data.Properties.VariableUnits = {'[s]','[\Omega^-1]','[°C]','[°C]','[pixel #]','[pixel #]'};

degreeSymbol = char(176);
newYlabels = ["time [s]","G diff [Ohm^-1]"," deltaT massimi [K]","deltaT minimi [K]","area max [pixel #]","area min [pixel #]"];
plt = stackedplot(data,'Title','Stacked Data','DisplayLabels',newYlabels, 'XVariable','times [s]');
grid on;
%pltax = plt.NodeChildren(end/2+1:end);
%for K = pltax.'; K.YLabel.Interpreter = 'tex'; end

subplot(3,1,1)
plot(times, DeltaConduct)
subplot(3,1,2)
plot(times, T_max)
subplot(3,1,3)
plot(times, T_min)

%stackedplot(times,tabella_5);
%xlabel('time [s]');
%stackname = [filename,'_calibFr_', num2str(calibr_frame),'_stack5pixel_',num2str(pixel_away_from_CAF),'_frames_', num2str(Frames(1)),'-',num2str(Frames(2)),'.fig'];
%savefig(stacked,[path,stackname]); %'\'

%get y position
% % [max_peaks, min_peaks, Eventi_termo_ripuliti, matriceEventi] = evento_max_temp_007_matriceEventi(Th_rs_, Th_rs, Eventi_Termo, frame_start, fr_diff);
% % y_max = zeros(length(max_peaks(:,1)),1);
% % y_min = zeros(length(min_peaks(:,1)),1);
% % for i = 1: length(max_peaks(:,1))
% %     x_max = ceil(max_peaks(i,1)./Rows);
% %     x_min = ceil(min_peaks(i,1)./Rows);
% % 
% %     if x_max == 0
% %         y_max(i,1) = 0;
% %     else
% %         y_max(i,1) = max_peaks(i,1) - Rows*(x_max-1);
% %     end
% % 
% %     if x_min == 0
% %         y_min(i,1) = 0;
% %     else
% %         y_min(i,1) = min_peaks(i,1) - Rows*(x_min-1);
% %     end
% % end
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %ANALISI
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%% T vs A %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % if plot_TvsA == 1
% %     plotTvsA(max_peaks, min_peaks, T_max, T_min, area_max, area_min)
% % end
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%% R vs T %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % if plot_RvsT == 1
% %     delta_t = 0.20;
% %     plotRvsT_daTermo(delta_t, resistance, El_rs_, matriceEventi)    
% % end
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Traccia Picchi %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % if trace_peaks == 1
% %     tracepeaks(max_peaks, min_peaks, Rows, Columns, 0)
% % end
% % 
% % %%%%%%%%%%%%%%Comaparison position of couples event%%%%%%%%%%%%%%%%%%%%%%%
% % if couple_comparison == 1
% %     comparison_couple_events(max_peaks, min_peaks, Rows, Columns,0)
% % 
% %     %Confronto massimi simili e i loro minimi associati
% %     associated_points(max_peaks, min_peaks, Rows, Columns, 1)
% % 
% %     %Confronto minimi simili e i loro massimi associati
% %     associated_points(min_peaks, max_peaks, Rows, Columns, 1)
% % end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end