function main_ElecTher_switch_006(ElectrFilename, ThermalFilename, coordname, Nframes, frame_start, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-12 Last modification: 2023-12-06
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
plot_RvsT = 1;
trace_peaks = 0;
couple_comparison = 0;

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
[Th_rs, Rows, Columns] = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0); %aggiungi 'method', area method, detection method
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANALISI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[max_peaks, min_peaks] = evento_max_temp_003(Th_rs_);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% T vs A %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_TvsA == 1
    figure
    sgtitle('T vs A')
    
    for i = 1: length(max_peaks(:,1))
        subplot(2,1,1)
        hold on
            if(max_peaks(i,1) ~=0 & max_peaks(i,2)~=0)
                plot(T_max(max_peaks(i, 4)), area_max(max_peaks(i, 4)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
                xlabel('Temperature difference [°C]');
                ylabel('Area [#pixels]');
                title('Positive events');
            end
        hold off
        
        subplot(2,1,2)
        hold on
            if(min_peaks(i,1) ~=0 & min_peaks(i,2)~=0)
                plot(T_min(min_peaks(i, 4)), area_min(min_peaks(i, 4)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
                xlabel('Temperature difference [°C]');
                ylabel('Area [#pixels]');
                title('"Negative events');
            end
        hold off
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% R vs T %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_RvsT == 1
    delta_t = 0.20;
    resistance_events = [resistance, El_rs_(:, end-1)];
    [eventi_pos, eventi_neg] = cerca_evento_termo_004(max_peaks, min_peaks, resistance_events, delta_t);
    %save('switch.mat', 'resistance')
    figure
    sgtitle('R vs T')

    subplot(2,1,1)
    hold on
    if isempty(eventi_pos) == 0
        plot(eventi_pos(:,1), eventi_pos(:,2), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    end
    xlabel('Resistence difference [Ohm]');
    ylabel('Temperature difference [°C]');
    title('Positive events');
    hold off

    subplot(2,1,2)
    hold on
    if isempty(eventi_neg) == 0
        plot(eventi_neg(:,1), eventi_neg(:,2), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    end
    xlabel('Resistence difference [Ohm]');
    ylabel('Temperature difference [°C]');
    title('Negative events');
    hold off
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Traccia Picchi %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trace_peaks == 1
    %elimino gli zeri da max_peaks e min_peaks
    i = 1;
    max_peaks_clean = max_peaks;
    min_peaks_clean = min_peaks;

    while i <= length(max_peaks_clean(:,1))
        if max_peaks_clean(i,1) ==0 & max_peaks_clean(i,2)==0
            max_peaks_clean(i,:) = [];
            i = i-1;
        end
        i = i+1;
    end
    
    i = 1;
    while i <= length(min_peaks_clean(:,1))
        if min_peaks_clean(i,1) == 0 & min_peaks_clean(i,2) == 0
            min_peaks_clean(i,:) = [];
            i = i-1;
        end
        i = i+1;
    end
    
    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    
    figure
    colormap('jet')
    sgtitle('Events peaks positions')

    subplot(2,1,1)
    hold on
        if isempty(max_peaks_clean) == 0
            cm = colormap(jet);
            numPoints = length(max_peaks_clean(:,1));

            x = data_x(max_peaks_clean(:, 1));
            y = data_y(max_peaks_clean(:, 1));
            z = 1:1:numPoints;
            z = z';
            
            scatter3(x,y,z,20,z,'filled', 'MarkerEdgeColor', 'black')

            h = surf([x(:) x(:)],[y(:) y(:)],[z(:) z(:)]);
            set(h,'facecolor','none','edgecolor','interp');
            set(h,'linewidth',1)

            clim([min(z(:,1)) numPoints])
            colormap(subplot(2,1,1), cm)
            colorbar(subplot(2,1,1))
            view(2)
            %text(x, y, num2str(max_peaks(:, 3)))
        end
        ylim([0 Rows]);
        xlim([0 Columns]);
        xlabel('[n° pixel]');
        ylabel('[n° pixel]');
        title('Hot events');
    hold off

    subplot(2,1,2)
    hold on
        if isempty(min_peaks_clean) == 0
            cm = colormap(jet);
            numPoints = length(min_peaks_clean(:,1));

            x = data_x(min_peaks_clean(:, 1));
            y = data_y(min_peaks_clean(:, 1));
            z = 1:1:numPoints;
            z = z';
            
            scatter3(x,y,z,20,z,'filled', 'MarkerEdgeColor', 'black')

            h = surf([x(:) x(:)],[y(:) y(:)],[z(:) z(:)]);
            set(h,'facecolor','none','edgecolor','interp');
            set(h,'linewidth',1)
            clim([min(z(:,1)) numPoints])
            colormap(subplot(2,1,2), cm)
            colorbar(subplot(2,1,2))
            view(2)
            %text(x, y, num2str(min_peaks(:, 3)))
        end
        ylim([0 Rows]);
        xlim([0 Columns]);
        xlabel('[n° pixel]');
        ylabel('[n° pixel]');
        title('Cold events');            
    hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%Comaparison position of couples event%%%%%%%%%%%%%%%%%%%%%%%
if couple_comparison == 1
    max_peaks_couple = zeros(0, 4);
    min_peaks_couple = zeros(0, 4);
 
    for i = 1 : length(max_peaks(:,1))
        if max_peaks(i, 1) ~= 0 & max_peaks(i, 2) ~= 0 & min_peaks(i, 1) ~= 0 & min_peaks(i, 2) ~= 0 %verifico se ho un evento coppia
            max_peaks_couple(end+1, :) = max_peaks(i,:);
            min_peaks_couple(end+1, :) = min_peaks(i, :);
        end
    end
    
    %grafico delle coppie
    figure
    colormap('jet')
    title('Couple events position')
    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    hold on
    if isempty(min_peaks_couple) == 0 & isempty(max_peaks_couple) == 0

            x_max = data_x(max_peaks_couple(:,1));
            y_max = data_y(max_peaks_couple(:,1));
            z_max = max_peaks_couple(:,3);

            x_min = data_x(min_peaks_couple(:,1));
            y_min = data_y(min_peaks_couple(:,1));
            z_min = min_peaks_couple(:,3);
            
            scatter3(x_max,y_max,z_max, 20, z_max, 'o', 'filled', 'MarkerEdgeColor', 'black')
            scatter3(x_min,y_min,z_min,20,z_min, 'Pentagram', 'filled', 'MarkerEdgeColor', 'black')
            
            if size(z_min) ~= 1
                h_max = surf([x_max(:) x_max(:)],[y_max(:) y_max(:)],[z_max(:) z_max(:)]);
                set(h_max,'facecolor','none','edgecolor','interp');
                set(h_max,'linewidth',1)
                view(2)
    
                h_min = surf([x_min(:) x_min(:)],[y_min(:) y_min(:)],[z_min(:) z_min(:)]);
                set(h_min,'facecolor','none','edgecolor','interp');
                set(h_min,'linewidth',1)
            end

            % text(x_max, y_max, num2str(max_peaks_couple(:, 3)))
            % text(x_min, y_min, num2str(min_peaks_couple(:, 3)))
    end
        clim([0 numPoints])
        colorbar
        view(2)
        ylim([0 Rows]);
        xlim([0 Columns]);
        xlabel('[n° pixel]');
        ylabel('[n° pixel]');
    hold off

    %Confronto massimi simili e i loro minimi associati
    max_restanti = max_peaks_couple;
    min_restanti = min_peaks_couple;

    figure
    colormap('jet')
    title('Confronto tra punto caldo e punti freddi associati')

    j = 1;
    
    hold on
    while j <= length(max_restanti(:,1))
        max_ragg = zeros(0, 4);
        min_ragg = zeros(0, 4);
    
        max_ragg(1, :) = max_restanti(1, :);
        min_ragg(1, :) = min_restanti(1, :);
        
        max_restanti(1, :) = [];
        min_restanti(1, :) = [];
        
        i = 1;
        while i <= length(max_restanti(:,1))
            state = raggruppo_2eventi(max_ragg(1,1), max_ragg(1, 2), max_restanti(i, 1), max_restanti(i, 2), Rows, Columns);
    
            if state == 1
                max_ragg(end+1, :) = max_restanti(i, :);
                min_ragg(end+1, :) = min_restanti(i, :);
    
                max_restanti(i, :) = [];
                min_restanti(i, :) = [];
    
                i = i-1;
            end
            i = i+1;
        end

        x_max = data_x(max_ragg(:,1));
        y_max = data_y(max_ragg(:,1));
        
        x_min = data_x(min_ragg(:,1));
        y_min = data_y(min_ragg(:,1));

        z = zeros(length(min_ragg(:,1)), 1);
        z(1:end, 1) = j;

        scatter3(x_max, y_max, z, 70, z, 'o', 'filled', 'MarkerEdgeColor', 'black')
        scatter3(x_min, y_min, z, 70, z, 'Pentagram', 'filled', 'MarkerEdgeColor', 'black')
        
        str = append('#max=', num2str(length(max_ragg(:,1))), newline,'#min=', num2str(length(min_ragg(:,1))));
        text(x_max(1,1), y_max(1,1), z(1,1), str)

        z_grid = zeros(Rows, Columns);
        z_grid(:,:) = j;
        mesh(z_grid, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'EdgeColor', 'black');
        
        clim([0 j])
        colorbar
        view(2)
        j = j+1;
    end
    ylim([0 Rows]);
    xlim([0 Columns]);
    xlabel('[n° pixel]');
    ylabel('[n° pixel]');
    hold off

    %Confronto minimi simili e i loro massimi associati
    max_restanti = max_peaks_couple;
    min_restanti = min_peaks_couple;

    figure
    colormap('jet')
    title('Confronto tra punto freddo e punti caldi associati')

    j = 1;
    
    hold on
    while j <= length(min_restanti(:,1))
        max_ragg = zeros(0, 4);
        min_ragg = zeros(0, 4);
    
        max_ragg(1, :) = max_restanti(1, :);
        min_ragg(1, :) = min_restanti(1, :);
        
        max_restanti(1, :) = [];
        min_restanti(1, :) = [];
        
        i = 1;
        while i <= length(min_restanti(:,1))
            state = raggruppo_2eventi(min_ragg(1,1), min_ragg(1, 2), min_restanti(i, 1), min_restanti(i, 2), Rows, Columns);
    
            if state == 1
                min_ragg(end+1, :) = min_restanti(i, :);
                max_ragg(end+1, :) = max_restanti(i, :);
    
                max_restanti(i, :) = [];
                min_restanti(i, :) = [];
    
                i = i-1;
            end
            i = i+1;
        end

        x_min = data_x(min_ragg(:,1));
        y_min = data_y(min_ragg(:,1));
        
        x_max = data_x(max_ragg(:,1));
        y_max = data_y(max_ragg(:,1));

        z = zeros(length(max_ragg(:,1)), 1);
        z(1:end, 1) = j;

        scatter3(x_min, y_min, z, 70, z, 'o', 'filled', 'MarkerEdgeColor', 'black')
        scatter3(x_max, y_max, z, 70, z, 'Pentagram', 'filled', 'MarkerEdgeColor', 'black')
        
        str = append('#min=', num2str(length(min_ragg(:,1))), newline,'#max=', num2str(length(max_ragg(:,1))));
        text(x_min(1,1), y_min(1,1), z(1,1), str)
        
        z_grid = zeros(Rows, Columns);
        z_grid(:,:) = j;
        mesh(z_grid, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'EdgeColor', 'black');


        clim([0 j])
        colorbar
        view(2)
        j = j+1;
    end
    ylim([0 Rows]);
    xlim([0 Columns]);
    xlabel('[n° pixel]');
    ylabel('[n° pixel]');
    hold off
end

























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end