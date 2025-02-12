function sttc_images()

% dat = load(filename);
% dat = dat.group1;
% %dat(dat(:,2)==1,1)
% figure
% axis([0,300,0,1])
% gridxy(dat(dat(:,2)==1,1)')

fig = openfig('19_07_24_E26_D6_1mmA_f9_ALL_STTC_from_start_to_60_s___dist.fig');
axesHandles = findall(fig, 'type', 'axes');

ax1 = axesHandles(1); % Get the current axes
ax2 = axesHandles(2); % Get the current axes

scatterObj = findobj(ax1, 'Type', 'Scatter');

figure

for i = 1:length(scatterObj)
    xData = scatterObj(i).XData;
    yData = scatterObj(i).YData;
    zData = scatterObj(i).ZData;
    T_rem = array2table([xData',yData',zData'],'VariableNames',{'Active Sites distance [\mum]','syncronicity window [s]','sttc'});
    c = zData;      %# colors
    h = surface([xData(:), xData(:)], [yData(:), yData(:)], [zData(:), zData(:)], [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none','LineWidth',2);
    hold on
end

grid on

title('0 s - 60 s')
xlabel('Active Sites distance [\mum]')
ylabel('syncronicity window [s]')
zlabel('STTC')
zlim([-1,1])
clim([-1,1])

colorbar

scatterObj = findobj(ax2, 'Type', 'Scatter');

figure


for i = 1:length(scatterObj)
    xData = scatterObj(i).XData;
    yData = scatterObj(i).YData;
    zData = scatterObj(i).ZData;
    T_rem = array2table([xData',yData',zData'],'VariableNames',{'Active Sites distance [\mum]','syncronicity window [s]','sttc'});
    c = zData;      %# colors
    h = surface([xData(:), xData(:)], [yData(:), yData(:)], [zData(:), zData(:)], [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none','LineWidth',2);
    hold on
end

grid on

title('60 s - 300 s')
xlabel('Active Sites distance [\mum]')
ylabel('syncronicity window [s]')
zlabel('STTC')
zlim([-1,1])
clim([-1,1])
colorbar

% figure
% plot3(xData,yData,zData)
% colorbar
%hold off

%plt = scatter3(T_rem,'Active Sites distance [\mum]','syncronicity window [s]','sttc','filled','ColorVariable','sttc');


end