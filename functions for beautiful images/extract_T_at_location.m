function extract_T_at_location(fr)

cd termoFiles_mat\
load("mtotalT.mat")
load('ThermoColorMap2.mat');

imagesc(mtotalT(:,:,fr))
colormap(cm)
pause
location = ginput(1);
location = round(location);
time_serie = squeeze(mtotalT(location(2),location(1),:));

plot(time_serie)
pause

location = ginput(1);
location = round(location);
figure
imagesc(mtotalT(:,:,location(1)))
colormap(cm)
colorbar
figure
imagesc(mtotalT(:,:,location(1)+1))
colormap(cm)
colorbar
figure
imagesc(mtotalT(:,:,location(1)+2))
colormap(cm)
colorbar
figure
imagesc(mtotalT(:,:,location(1)+3))
colormap(cm)
colorbar

m = mtotalT(:,:,location(1):location(1)+4);
dm = diff(m,1,3);
max_ = max(abs(dm),[],'all');
figure
imagesc(dm(:,:,1))
colormap(cm)
max__ = max(abs(dm(:,:,1)),[],'all');
clim([-max__,max__])
colorbar
figure
imagesc(dm(:,:,2))
colormap(cm)
max__ = max(abs(dm(:,:,2)),[],'all');
clim([-max__,max__])
colorbar
figure
imagesc(dm(:,:,3))
colormap(cm)
max__ = max(abs(dm(:,:,3)),[],'all');
clim([-max__,max__])
colorbar
figure
imagesc(dm(:,:,4))
colormap(cm)
max__ = max(abs(dm(:,:,4)),[],'all');
clim([-max__,max__])
colorbar

cd ..

end