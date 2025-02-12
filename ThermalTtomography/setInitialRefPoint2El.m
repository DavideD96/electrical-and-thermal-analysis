function setInitialRefPoint2El(filename,frame)

% This function is called at the beginning of each tomography session in
% wich is required to compare different thermal images (different folders)
% You need to specify the filename (something like 
% 'E26_4Elst_C1_2mm_3-8_IMP1V_f44_-098_'), and a frame BE CAREFULL, INCLUDE '_'.
% The program allows to set the ROI (i.e., the CAF), by clicking top left
% and bottom right boundary pixels. Then, you must indicate the refPoint,
% that is a reference pixel used to choose the ROI in the following files.
% Then it ask also to set the goove areas IN A WELL DEFINED SEQUENCE (be
% careful!!): 1) a-b/3-6, 2) b-c/3-8, 3) c-a/2-8.
%
% The program saves:
%
% CAF_coordinates.mat
% ref1_coordinates.mat
% groove_a-b_3-6_coordinates.mat
% groove_b-c_3-8_coordinates.mat
% groove_c-a_2-8_coordinates.mat



CAF_coordinates = locate_CAF(filename,frame);
close all;

CAF_coordinates = round(CAF_coordinates);
AvioFlir = 1;
load('ThermoColorMap2.mat','cm');

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

matfilename=sprintf(append(filename,'CAF_coordinates.mat'));
coordinates = CAF_coordinates;
save(matfilename,'coordinates','filename');
save(append(filename,'ref1_coordinates.mat'),'ref_coordinates','filename');
close all;

%set grooves
figure
imagesc(m(CAF_coordinates(1,2):CAF_coordinates(3,2),CAF_coordinates(1,1):CAF_coordinates(3,1)));
colormap("parula");
title('set a-b/1-2 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove_coordinates = [x,y]; %Rab 
groove_coordinates = [groove_coordinates;x(2),y(2)];
groove_coordinates(2,:) = [x(2),y(1)];

groove_coordinates(:,1) = round(groove_coordinates(:,1));
groove_coordinates(:,2) = round(groove_coordinates(:,2));
save(append(filename,'groove_coordinates.mat'),'groove_coordinates','filename');

answer = inputdlg({'store mtotalT (1) or not (0)?'});
if answer{1} == '1'
    store_mtotalT8cores(filename,399,append(filename,'CAF_coordinates.mat'));
    findRiseFall(2,180,200);
end
end