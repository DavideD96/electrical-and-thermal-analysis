f1 = 224;
f2 = 249;

cd(append('E:\09_04_24_termoR\2024Apr09\',num2str(f1)))

check = exist("Data.mat","file");

if check ~= 0
    data1 = cell2mat(struct2cell(load("Data.mat")));
else
    plot_Keithley2606b('Data.txt',0)
    data1 = cell2mat(struct2cell(load("Data.mat")));
end

cd(append('E:\09_04_24_termoR\2024Apr09\',num2str(f2)))

check = exist("Data.mat","file");

if check ~= 0
    data2 = cell2mat(struct2cell(load("Data.mat")));
else
    plotRS_Keithley2606B('Data.txt',0)
    data2 = cell2mat(struct2cell(load("Data.mat")));
end

data2(:,1) = data2(:,1) + data1(end,1);
data = [data1;data2];

a = figure;
plot(data(:,1),1./data(:,4),'LineWidth',2);
title(append(num2str(f1),'__',num2str(f2)), 'FontSize', 15);
fontsize(a, 15, "points")
ylabel('[\Omega^{-1}]')
grid on
hold off

cd ..
cd grafici

saveas(a,append(num2str(f1),'_',num2str(f2),'.png'),'png')
cd ..
