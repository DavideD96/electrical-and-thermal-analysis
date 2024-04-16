function setInitialRefPoint(filename,frame)

coordinates = locate_CAF(filename,frame);

coordinates = round(coordinates);
AvioFlir = 1;
load('ThermoColorMap1.mat','cm');

if AvioFlir == 0
    m=readtable(sprintf(append(filename,'%d.CSV'),frame),'Range','B9:XQ488');
elseif AvioFlir == 1
    m=readtable(sprintf(append(filename,'%d.csv'),frame));
end

m= m{:,:};
imagesc(m(coordinates(1,2):coordinates(3,2),coordinates(1,1):coordinates(3,1)));
colormap("parula");
pause;

[x,y] = ginput(1); %ref1, respect to new boundaries! ref2 (avoid rotations)
ref_coordinates = [x,y];

matfilename=sprintf(append(filename,'CAF_coordinates.mat'));
save(matfilename,'coordinates','filename');
save(append(filename,'ref1_Coordinates.mat'),'ref_coordinates','filename');

end