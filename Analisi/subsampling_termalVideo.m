function subsampling_termalVideo(fr)

m = load("mtotalT.mat");
m = m.mtotalT;

%select hotspot
imagesc(m(:,:,fr));
pause;
[x,y] = ginput(1);
hot_coordinates = [round(x),round(y)];

Ttimeseries = m(hot_coordinates(2),hot_coordinates(1),:);
Ttimeseries = squeeze(Ttimeseries);

figure
plot(Ttimeseries)
pause;
[x,~] = ginput(1);
frame_impulso = round(x);

subsampled_m = m(:,:,frame_impulso:20:end);

save('subsampled_m',"subsampled_m")