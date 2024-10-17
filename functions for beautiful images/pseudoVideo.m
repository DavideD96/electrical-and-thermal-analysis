frames = [84,2414,2646,2856,13116];

% cd parameters\
% par = load('ThermalParameters.mat');
% delay = par.delay;
% cd ..

%cd termoFiles_mat\

figure
appendedM = [mtotalT(:,:,frames(1)),mtotalT(:,:,frames(2)),mtotalT(:,:,frames(3))];
limits = [min(appendedM,[],'all'),max(appendedM,[],'all')];

tiledlayout(1,5);

for ii = 1:5
    nexttile
    imagesc(mtotalT(:,:,frames(ii)))
    clim(limits)
    axis equal
    axis off
end

load('ThermoColorMap3.mat')
colormap(cm)
%colorbar