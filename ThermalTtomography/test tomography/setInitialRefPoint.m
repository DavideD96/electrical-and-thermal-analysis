function setInitialRefPoint(filename,frame)

% This function is called at the beginning of each tomography session in
% wich is required to compare different thermal images (different folders)
% You need to specify the filename (something like 
% 'E26_4Elst_C1_2mm_3-8_IMP1V_f44_-098_'), and a frame.
% The program saves:
%
% CAF_coordinates.mat
% ref1_coordinates.mat
% groove_c-a_2-8_coordinates.mat
% groove_a-b_3-6_coordinates.mat
% groove_b-c_3-8_coordinates.mat


CAF_coordinates = locate_CAF(filename,frame);
close all;

CAF_coordinates = round(CAF_coordinates);
AvioFlir = 1;
load('ThermoColorMap1.mat','cm');

if AvioFlir == 0
    m=readtable(sprintf(append(filename,'%d.CSV'),frame),'Range','B9:XQ488');
elseif AvioFlir == 1
    m=readtable(sprintf(append(filename,'%d.csv'),frame));
end

m= m{:,:};
imagesc(m(CAF_coordinates(1,2):CAF_coordinates(3,2),CAF_coordinates(1,1):CAF_coordinates(3,1)));
colormap("parula");
title('set refPoint')
pause;

[x,y] = ginput(1); %ref1, respect to new boundaries! ref2 (avoid rotations)
ref_coordinates = [round(x+CAF_coordinates(1,1)-1),round(y+CAF_coordinates(1,2)-1)];

matfilename=sprintf(append(filename,num2str(frame),'_CAF_coordinates.mat'));
save(matfilename,'CAF_coordinates','filename');
save(append(filename,num2str(frame),'_ref1_coordinates.mat'),'ref_coordinates','filename');
close all;

%set grooves
figure
imagesc(m(CAF_coordinates(1,2):CAF_coordinates(3,2),CAF_coordinates(1,1):CAF_coordinates(3,1)));
colormap("parula");
title('set a-b/1-2 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove1_coordinates = [x,y]; %Rab 
groove1_coordinates = [groove1_coordinates;x(2),y(2)];
groove1_coordinates(2,:) = [x(2),y(1)];

groove1_coordinates(:,1) = round(groove1_coordinates(:,1));
groove1_coordinates(:,2) = round(groove1_coordinates(:,2));
save(append(filename,num2str(frame),'_groove_a-b_3-6_coordinates.mat'),'groove1_coordinates','filename');
 
title('set b-c/2-3 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove2_coordinates = [x,y]; %Rab 
groove2_coordinates = [groove2_coordinates;x(2),y(2)];
groove2_coordinates(2,:) = [x(2),y(1)];

groove2_coordinates(:,1) = round(groove2_coordinates(:,1));
groove2_coordinates(:,2) = round(groove2_coordinates(:,2));
save(append(filename,num2str(frame),'_groove_b-c_3-8_coordinates.mat'),'groove2_coordinates','filename');

title('set c-a/1-3 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove3_coordinates = [x,y]; %Rab 
groove3_coordinates = [groove3_coordinates;x(2),y(2)];
groove3_coordinates(2,:) = [x(2),y(1)];

groove3_coordinates(:,1) = round(groove3_coordinates(:,1));
groove3_coordinates(:,2) = round(groove3_coordinates(:,2));
save(append(filename,num2str(frame),'_groove_c-a_2-8_coordinates.mat'),'groove3_coordinates','filename');
 
end