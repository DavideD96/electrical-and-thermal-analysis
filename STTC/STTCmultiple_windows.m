function sttc = STTCmultiple_windows(series1,series2,deltat_int,npoints,varargin)

mat_or_work = 0;
plot_fig = 1;
save = 1;
num = length(varargin);
window = 0;

for i = 1:2:num
    if prod(varargin{i} == 'mat_or_work')
        mat_or_work = varargin{i+1};
    elseif prod(varargin{i} == 'plot_figure')
        plot_fig = varargin{i+1};
    elseif prod(varargin{i} == 'save_figure')
        save = varargin{i+1};
    elseif prod(varargin{i} == 'reduce_wind') %reduce lenght recording
        window = varargin{i+1};    
    end
end

if window ~= 0
    sttc_reduc = zeros(npoints,2);
    sttc_remai = zeros(npoints,2);
end

deltat = linspace(deltat_int(1),deltat_int(2),npoints);
sttc = zeros(npoints,2);
for i = 1:npoints
    sttc(i,1) = deltat(i);
    if mat_or_work == 1
        if window ~= 0
            sttc_reduc(i,1) = deltat(i);
            sttc_remai(i,1) = deltat(i);
            [sttc(i,2), nA, nB] = STTC_001(series1,series2,deltat(i),'reduce_wind',0,'mat_or_work',1);
            [sttc_reduc(i,2), nA_reduc, nB_reduc] = STTC_001(series1,series2,deltat(i),'reduce_wind',window,'mat_or_work',1);
            [sttc_remai(i,2), ~, ~] = STTC_RemainingDelenda_001(series1,series2,deltat(i),'reduce_wind',window,'mat_or_work',1);
        else
            [sttc(i,2), nA, nB] = STTC_001(series1,series2,deltat(i),'reduce_wind',0,'mat_or_work',1);
        end        
    else
        if window ~= 0
            sttc_reduc(i,1) = deltat(i);
            sttc_remai(i,1) = deltat(i);
            [sttc(i,2), nA, nB] = STTC_001(series1,series2,deltat(i),'reduce_wind',0);
            [sttc_reduc(i,2), nA_reduc, nB_reduc] = STTC_001(series1,series2,deltat(i),'reduce_wind',window);
            [sttc_remai(i,2), ~, ~] = STTC_RemainingDelenda_001(series1,series2,deltat(i),'reduce_wind',window);
        else
            [sttc(i,2), nA, nB] = STTC_001(series1,series2,deltat(i),'reduce_wind',0);
        end
    end
end

if mat_or_work == 1
    newStr1 = num2str(series1);
    newStr2 = num2str(series2);
else
    newStr1 = erase(series1,'.mat');
    newStr2 = erase(series2,'.mat');
end



if plot_fig == 1
    a = figure;
    plot(sttc(:,1),sttc(:,2))
    hold on
    if window ~= 0
        plot(sttc_reduc(:,1),sttc_reduc(:,2))
        plot(sttc_remai(:,1),sttc_remai(:,2))
        title(append(newStr1,' VS ',newStr2, ' n eventi = ', num2str(nA),' (',num2str(nA_reduc),') ',num2str(nB),' (',num2str(nB_reduc),') '));
    else
        title(append(newStr1,' VS ',newStr2, ' n eventi = ', num2str(nA),' ',num2str(nB)));
    end
    xlabel('\Deltat [s]');
    ylabel('STTC [adim.]');
    legend('0-300 s',append('0-',num2str(window),' s'),append(num2str(window),'-300 s'))
    grid on
    hold off
end

if save == 1
    savefig(append(newStr1,' VS ',newStr2,' window ',num2str(window)));
    saveas(a,append(newStr1,' VS ',newStr2,' window ',num2str(window),'.png'),'png');
end

end