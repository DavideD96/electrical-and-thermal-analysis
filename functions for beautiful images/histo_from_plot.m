function histo_from_plot(figure_,n)

%figure = string

fig = openfig(figure_);
ax = findall(fig, 'Type', 'axes');
children = get(ax, 'Children');

% Estrai le due scale Y
yaxes = ax.YAxis;

leftYAxis = yaxes(1);  % di solito left
rightYAxis = yaxes(2); % di solito right

lines = findall(ax, 'Type', 'line');

t = lines(1).XData;
I = lines(1).YData;
V = lines(2).YData;

t = t(I ~= 0);
I = I(I ~= 0);
V = V(V ~= 0);

C = I./V;

min_ = -0.0001;
max_ = 0.0024;

min(C)-1e-5
max(C)+1e-5
edges_ = linspace(min_,max_,25 );

% [N,edges] = histcounts(C,20);
% nbin = length(edges)-1;

% figure
% histogram(C,edges);
% centres = edges+(edges(2)-edges(1))/2;
% centres = centres(1:end-1);

%n = 1;
title('select sections')
pause
sel = ginput(n);

% fig = openfig(figure_);
% xline(5, '--r', 'Label');


sel = [-3e-5,-3e-5;sel];
groups = cell(n+1,1);

for ii = 2:n+1
    ind = all([t' < sel(ii,1), t' >= sel(ii-1,1)],2);
    groups{ii-1} = C(ind(1:end-1));
end
ind = t' > sel(end,1);
groups{end} = C(ind(1:end-1));

%groups

% for ii = 2:n+1
% 
%     ind = all([edges' < sel(ii,1), edges' >= sel(ii-1,1)],2);
%     groups{ii-1} = N(ind(1:end-1));
% end
% ind = edges' > sel(end,1);
% groups{end} = N(ind(1:end-1));
% groups
close all


%xline(5, '--r', 'Label');


facecolors = {'yellow','red','cyan','green','blue','black'};

figure
hold on
for ii = 2:n+1
    facecolors{ii}
histogram(groups{ii},edges_,'FaceColor',facecolors{ii})
xlim([-0.0001, 0.0024]);
%bar(centers, counts, 'hist');
end

xlabel('Conductance [\Omega^{-1}]')
ylabel('Counts')
grid on

% set(gcf, 'Color', 'none');      % Rende trasparente il background della figura
% set(gca, 'Color', 'none');
% set(gcf, 'Renderer', 'painters');  % Renderer compatibile

exportgraphics(gcf, 'plot_trasparente.png', 'BackgroundColor', 'none');
% exportgraphics(gca, 'grafico_trasparente.png', 'BackgroundColor', 'none');

hold off
% x = get(children(1), 'XData');
% y = get(children(1), 'YData');
% 
% left_lines = findobj(ax, 'YAxisLocation', 'left');
% right_lines = findobj(ax, 'YAxisLocation', 'right');
% 
% axObjs = fig.Children;
% dataObjs = axObjs.Children;
% 
% x = dataObjs(1).XData;
% y = dataObjs(1).YData;

end