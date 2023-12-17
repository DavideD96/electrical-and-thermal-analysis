function main_ElecTher_switch_007(ElectrFilename, ThermalFilename, coordname, Nframes, frame_start, varargin)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inizializzazione
%PARAMETRI DI DEFAULT
plot_TvsA = 0;
plot_RvsT = 0;
trace_peaks = 1;
couple_comparison = 0;
power_consideration = 0;

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
[Th_rs, Rows, Columns] = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0, 'PowerCons', power_consideration); %aggiungi 'method', area method, detection method
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

%get y position
[max_peaks, min_peaks] = evento_max_temp_003(Th_rs_);
y_max = zeros(length(max_peaks(:,1)),1);
y_min = zeros(length(min_peaks(:,1)),1);
for i = 1: length(max_peaks(:,1))
    x_max = ceil(max_peaks(i,1)./Rows);
    x_min = ceil(min_peaks(i,1)./Rows);
    
    if x_max == 0
        y_max(i,1) = 0;
    else
        y_max(i,1) = max_peaks(i,1) - Rows*(x_max-1);
    end
    
    if x_min == 0
        y_min(i,1) = 0;
    else
        y_min(i,1) = min_peaks(i,1) - Rows*(x_min-1);
    end
end

resistance = El_rs_(:,end);
T_max = Th_rs_(:,4);
T_min = Th_rs_(:,5);
area_max = Th_rs_(:,6);
area_min = Th_rs_(:,7);

data = table(times, resistance,T_max,T_min,area_max,area_min, y_max, y_min);
data = renamevars(data,'times','times [s]');

data.Properties.VariableUnits = {'[s]','[\Omega]','[°C]','[°C]','[pixel #]','[pixel #]', '[pixel #]','[pixel #]'};

degreeSymbol = char(176);
newYlabels = ["time [s]","R diff [Ohm]"," T max ["+ degreeSymbol + "C]","T min ["+ degreeSymbol + "C]","area max [pixel #]","area min [pixel #]", "y max [pixel #]","y min [pixel #]"];
plt = stackedplot(data,'Title','Stacked Data','DisplayLabels',newYlabels, 'XVariable','times [s]');
grid on;
%pltax = plt.NodeChildren(end/2+1:end);
%for K = pltax.'; K.YLabel.Interpreter = 'tex'; end

%stackedplot(times,tabella_5);
%xlabel('time [s]');
%stackname = [filename,'_calibFr_', num2str(calibr_frame),'_stack5pixel_',num2str(pixel_away_from_CAF),'_frames_', num2str(Frames(1)),'-',num2str(Frames(2)),'.fig'];
%savefig(stacked,[path,stackname]); %'\'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANALISI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% T vs A %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_TvsA == 1
    plotTvsA(max_peaks, min_peaks, T_max, T_min, area_max, area_min)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% R vs T %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_RvsT == 1
    delta_t = 0.20;
    plotRvsT(delta_t, resistance, El_rs_, max_peaks, min_peaks)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Traccia Picchi %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trace_peaks == 1
    tracepeaks(max_peaks, min_peaks, Rows, Columns, 0)
end

%%%%%%%%%%%%%%Comaparison position of couples event%%%%%%%%%%%%%%%%%%%%%%%
if couple_comparison == 1
    comparison_couple_events(max_peaks, min_peaks, Rows, Columns,0)
    
    %Confronto massimi simili e i loro minimi associati
    associated_points(max_peaks, min_peaks, Rows, Columns, 1)

    %Confronto minimi simili e i loro massimi associati
    associated_points(min_peaks, max_peaks, Rows, Columns, 1)
end

%%%%%%%%%%%%%%%%%%%%%%%Power consideration%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%utile in particolare per la corrente costante
if power_consideration == 1
    potenza = load('power_results.mat');
    potenza = cell2mat(struct2cell(potenza));
    figure
    hold on
        plot(potenza(:,3), potenza(:,1)./potenza(:,2), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
        yline(1);
        %plot(potenza(:,3), potenza(:,2), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold off
        xlabel('tempo [s]')
        ylabel('P(diss)/P(ass)')
        title('Rapporto tra potenza dissipata e assorbita negli eventi coppia')
        %legend('Potenza dissipata', 'Potenza assorbita')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end