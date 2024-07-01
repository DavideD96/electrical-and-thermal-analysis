function coordinates = locate_CAF(filename,frame)

%importante! inizia sempre a selezionare dall'angolo in alto a sinistra.
AvioFlir = 1;
load('ThermoColorMap1.mat');
colormap(cm);

if AvioFlir == 0
    m=readtable(sprintf(append(filename,'%d.CSV'),frame),'Range','B9:XQ488');
elseif AvioFlir == 1
    m=readtable(sprintf(append(filename,'%d.csv'),frame));
end
m= m{:,:};
imagesc(m);
title('set CAF area')
pause;
%[x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF
[x,y] = ginput(2); %top left bottom right
coordinates = [x,y];
coordinates = [coordinates;x(2),y(2)];
coordinates(2,:) = [x(2),y(1)];

matfilename=sprintf(append(filename,'CAF_coordinates.mat'));
save(matfilename,'coordinates','filename');

end