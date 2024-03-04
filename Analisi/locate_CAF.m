function coordinates = locate_CAF(filename,frame)

%importante! inizia sempre a selezionare dall'angolo in alto a sinistra.

load('ThermoColorMap1.mat');
colormap(cm);
m=readtable(sprintf(append(filename,'%d.CSV'),frame),'Range','B9:XQ488');
m= m{:,:};
imagesc(m);

pause;
[x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF

coordinates = [x,y];

matfilename=sprintf(append(filename,'CAF_coordinates.mat'));
save(matfilename,'coordinates','filename');

end