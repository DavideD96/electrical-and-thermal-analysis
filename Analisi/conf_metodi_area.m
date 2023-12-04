function conf_metodi_area(ThermalFilename, coordname, Nframes, frame_start)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-28 Last modification: 2023-11-28
%Authors: Cristina Zuccali
%conf_metodi_area(ThermalFilename, coordname, Nframes, frame_start, varargin)
%
%It compares areas calculated with the three different methods. For CWT it does (scale_factor)^2
%It also compares areas calculated with RGS method with different thresholds. 
%
%   'ThermalFilename' = principal part of the file name of frame (without number of frame and .CSV)
%   'coordname' = name of file with coordinates of the wanted region
%   'Nframes' = number of frames to be analysed.
%   'frame_start' = frame corresponding to electrical measumerement start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%controllo cartelle

check = exist('ThEl_Results');
if check ~= 7
    mkdir('ThEl_Results');
end
%save the folder path where save data
path = [pwd,'\ThEl_Results\',];

cd 'parameters'
ThermalParameters_ = load('ThermalParameters.mat');
cd ..

ThermalParameters = ThermalParameters_.ThermalParameters;


%%%%%%%%%%%%%%%%%%%%%%%%%% thermal parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%global
fr_diff = ThermalParameters.fr_diff;
%Nframes = 'all';
soglia_max = ThermalParameters.soglia_max;
soglia_min = ThermalParameters.soglia_min;
detectMeth = ThermalParameters.detectMeth;
Th_sampl_fr = ThermalParameters.smplFr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Thermal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Th_rs_CWT = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0, 'detecArea', 1, 'AreaMetho', 'CWT'); %aggiungi 'method', area method, detection method
Th_rs_BiW = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0, 'detecArea', 1, 'AreaMetho', 'BiW');

thresh_RGS = 0.5:0.1:0.9;
thresh_RGS = thresh_RGS';

for i = 1:size(thresh_RGS(:,1))
    soglia = append('soglia', num2str(thresh_RGS(i,1)*100));
    Th_rs_RGS.(soglia) = analisi_Nframes011(ThermalFilename, Nframes, frame_start, fr_diff, coordname, soglia_max, soglia_min, 'ThreshNN', 'makeVideo',0,'smoothing',0, 'detecArea', 1, 'AreaMetho', 'RGS', 'ThreshRGS', thresh_RGS(i,1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot confronti %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
sgtitle('RGS method thresholds comparison')

subplot(2,1,1)
hold on
    xlabel('time [s]');
    ylabel('Area [#pixels]');
    title('Positive events');
    
    for i = 1:size(thresh_RGS(:,1))
        soglia = append('soglia', num2str(thresh_RGS(i,1)*100));
        plot(Th_rs_RGS.(soglia)(:,1), Th_rs_RGS.(soglia)(:,6), 'DisplayName', soglia);
    end
    legend
hold off


subplot(2,1,2)
hold on
    xlabel('time [s]');
    ylabel('Area [#pixels]');
    title('Negative events');
    
    for i = 1:size(thresh_RGS(:,1))
        soglia = append('soglia', num2str(thresh_RGS(i,1)*100));
        plot(Th_rs_RGS.(soglia)(:,1), Th_rs_RGS.(soglia)(:,7), 'DisplayName', soglia);
    end
    legend
hold off

figure
sgtitle('Comparison of results from different are methods')

subplot(2,1,1)
hold on
    xlabel('time [s]');
    ylabel('Area [#pixels]');
    title('Positive events');
    
    soglia = append('soglia', num2str(80));
    plot(Th_rs_RGS.(soglia)(:,1), Th_rs_RGS.(soglia)(:,6), 'DisplayName', 'RGS, soglia = 0.8' );
    plot(Th_rs_BiW(:,1), Th_rs_BiW(:,6), 'DisplayName', 'BiW');
    plot(Th_rs_CWT(:,1), Th_rs_CWT(:,6).^2, 'DisplayName', 'CWT' );

    legend
hold off


subplot(2,1,2)
hold on
    xlabel('time [s]');
    ylabel('Area [#pixels]');
    title('Negative events');
    
    soglia = append('soglia', num2str(80));
    plot(Th_rs_RGS.(soglia)(:,1), Th_rs_RGS.(soglia)(:,7), 'DisplayName', 'RGS, soglia = 0.8' );
    plot(Th_rs_BiW(:,1), Th_rs_BiW(:,7), 'DisplayName', 'BiW');
    plot(Th_rs_CWT(:,1), Th_rs_CWT(:,7).^2, 'DisplayName', 'CWT' );

    legend
hold off


end