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

matfilename=sprintf(append(filename,num2str(frame),'_CAF_coordinates.mat'));
save(matfilename,'coordinates','filename');
save(append(filename,num2str(frame),'_ref1_coordinates.mat'),'ref_coordinates','filename');

%set grooves
figure
imagesc(m(coordinates(1,2):coordinates(3,2),coordinates(1,1):coordinates(3,1)));
colormap("parula");
title('set a-b/1-2 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove1_coordinates = [x,y]; %Rab 
groove1_coordinates = [groove1_coordinates;x(2),y(2)];
groove1_coordinates(2,:) = [x(2),y(1)];
save(append(filename,num2str(frame),'_groove_a-b_3-6_coordinates.mat'),'groove1_coordinates','filename');
 
title('set b-c/2-3 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove2_coordinates = [x,y]; %Rab 
groove2_coordinates = [groove2_coordinates;x(2),y(2)];
groove2_coordinates(2,:) = [x(2),y(1)];
save(append(filename,num2str(frame),'_groove_b-c_3-8_coordinates.mat'),'groove2_coordinates','filename');

title('set c-a/1-3 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove3_coordinates = [x,y]; %Rab 
groove3_coordinates = [groove3_coordinates;x(2),y(2)];
groove3_coordinates(2,:) = [x(2),y(1)];
save(append(filename,num2str(frame),'_groove_c-a_2-8_coordinates.mat'),'groove3_coordinates','filename');
 
end