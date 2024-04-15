function plot2res001(f1_,f2_)

ncoppie = 3;

ActMin = 2000;
ActMax = -40;
ActMaxDiff = 0;

DataStored = [];

for k = 1:ncoppie

f1 = f1_(k);
f2 = f2_(k);

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


max_(k) = max(1./data(:,4));
min_(k) = min(1./data(:,4));
diff_ = max_(k)-min_(k);

if max_(k) > ActMax
    ActMax = max_(k);
end
if min_(k) < ActMin
    ActMin = min_(k);
end
if diff_ > ActMaxDiff
    ActMaxDiff = diff_;
end

DataStored(:,:,k) = data;

end

for k = 1:ncoppie

f1 = f1_(k);
f2 = f2_(k);

a = figure;
plot(DataStored(:,1,k),1./DataStored(:,4,k),'LineWidth',2);
title(append(num2str(f1),'__',num2str(f2)), 'FontSize', 15);
fontsize(a, 15, "points")
ylabel('[\Omega^{-1}]')

offset = (ActMaxDiff)*0.05;
%ylim([ActMin-offset,ActMax+offset])
ylim([min_(k)-offset,min_(k)+ActMaxDiff+offset])
grid on
hold off

cd('E:\09_04_24_termoR\2024Apr09\grafici')

saveas(a,append(num2str(f1),'_',num2str(f2),'_lim.png'),'png')
cd ..

end
close all

end