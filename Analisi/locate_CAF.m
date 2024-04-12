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

pause;
[x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF

coordinates = [x,y];

matfilename=sprintf(append(filename,'CAF_coordinates.mat'));
save(matfilename,'coordinates','filename');

end