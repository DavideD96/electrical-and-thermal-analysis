function sttc = STTCmultiple_windows(series1,series2,deltat_int,npoints,varargin)

mat_or_work = 0;
plot_fig = 1;
save = 1;
num = length(varargin);

for i = 1:2:num
    if prod(varargin{i} == 'mat_or_work')
        mat_or_work = varargin{i+1};
    elseif prod(varargin{i} == 'plot_figure')
        plot_fig = varargin{i+1};
    elseif prod(varargin{i} == 'save_figure')
        save = varargin{i+1};
    end
end

deltat = linspace(deltat_int(1),deltat_int(2),npoints);
sttc = zeros(npoints,2);
for i = 1:npoints
    sttc(i,1) = deltat(i);
    if mat_or_work == 1
        [sttc(i,2), nA, nB] = STTC_001(series1,series2,deltat(i),'mat_or_work',1);
    else
        [sttc(i,2), nA, nB] = STTC_001(series1,series2,deltat(i));
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
    title(append(newStr1,' VS ',newStr2, ' n eventi = ', num2str(nA),' ',num2str(nB)));
    xlabel('\Deltat [s]');
    ylabel('STTC [adim.]');
    grid on
end

if save == 1
    savefig(append(newStr1,' VS ',newStr2));
    saveas(a,append(newStr1,' VS ',newStr2,'.png'),'png');
end

end