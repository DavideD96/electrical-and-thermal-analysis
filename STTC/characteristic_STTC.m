cd termoFiles_mat\

fig = openfig("ALL_STTC_dist.fig");


axObjs_all = fig.Children(2); %all
axObjs_red = fig.Children(4); %all
axObjs_rem = fig.Children(6); %all

gca = axObjs_all;

h_all = findall(gca, 'Type', 'Scatter');

xData_all = [];
yData_all = [];
zData_all = [];
xData_red = [];
yData_red = [];
zData_red = [];
xData_rem = [];
yData_rem = [];
zData_rem = [];

% h sarà un array di handle Scatter, uno per ogni serie
for i = 1:length(h_all)
    h_all(i).XData
    xData_all = [xData_all;h_all(i).XData];
    yData_all = [yData_all;h_all(i).YData];
    zData_all = [zData_all;h_all(i).ZData];
end

gca = axObjs_red;

h_red = findall(gca, 'Type', 'Scatter');

for i = 1:length(h_red)
    xData_red = [xData_red;h_red(i).XData];
    yData_red = [yData_red;h_red(i).YData];
    zData_red = [zData_red;h_red(i).ZData];
end

gca = axObjs_rem;

h_rem = findall(gca, 'Type', 'Scatter');

for i = 1:length(h_rem)
    xData_rem = [xData_rem;h_rem(i).XData];
    yData_rem = [yData_rem;h_rem(i).YData];
    zData_rem = [zData_rem;h_rem(i).ZData];
end

close all
cd ..

all = figure;
%zData_all
for ii = 1:size(h_all,1)

    hold on
    plot(yData_all(ii,:),zData_all(ii,:))

end

grid on
hold off

title('0 s - 300 s')
savefig(all,'STTC_all_vs_window')
saveas(all,'STTC_all_vs_window.png')

red = figure;

for ii = 1:size(h_red,1)

    hold on
    plot(yData_red(ii,:),zData_red(ii,:))

end

title('0 s - 60 s')
grid on
hold off

savefig(red,'STTC_reduced_vs_window')
saveas(red,'STTC_reduced_vs_window.png')

rem = figure;

for ii = 1:size(h_rem,1)

    hold on
    plot(yData_rem(ii,:),zData_rem(ii,:))

end

title('60 s - 300 s')
grid on
hold off

savefig(rem,'STTC_remaining_vs_window')
saveas(rem,'STTC_remaining_vs_window.png')

