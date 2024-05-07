function resetGrooves(filename,frame)

% This function reset the grooves.
% The program saves:
%
% groove_c-a_2-8_coordinates.mat
% groove_a-b_3-6_coordinates.mat
% groove_b-c_3-8_coordinates.mat

AvioFlir = 1;

if AvioFlir == 0
    m=readtable(sprintf(append(filename,'%d.CSV'),frame),'Range','B9:XQ488');
elseif AvioFlir == 1
    m=readtable(sprintf(append(filename,'%d.csv'),frame));
end

m = m{:,:};

CAF_coordinates = load(append(filename,'CAF_coordinates.mat'));
CAF_coordinates = CAF_coordinates.coordinates;
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
save(append(filename,'groove_a-b_3-6_coordinates.mat'),'groove1_coordinates','filename');
 
title('set b-c/2-3 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove2_coordinates = [x,y]; %Rab 
groove2_coordinates = [groove2_coordinates;x(2),y(2)];
groove2_coordinates(2,:) = [x(2),y(1)];

groove2_coordinates(:,1) = round(groove2_coordinates(:,1));
groove2_coordinates(:,2) = round(groove2_coordinates(:,2));
save(append(filename,'groove_b-c_3-8_coordinates.mat'),'groove2_coordinates','filename');

title('set c-a/1-3 groove');
pause
[x,y] = ginput(2); %ref1, respect to new boundaries! ref2 (avoid rotations)
groove3_coordinates = [x,y]; %Rab 
groove3_coordinates = [groove3_coordinates;x(2),y(2)];
groove3_coordinates(2,:) = [x(2),y(1)];

groove3_coordinates(:,1) = round(groove3_coordinates(:,1));
groove3_coordinates(:,2) = round(groove3_coordinates(:,2));
save(append(filename,'groove_c-a_2-8_coordinates.mat'),'groove3_coordinates','filename');
 

answer = inputdlg({'store mtotalT (1) or not (0)?'});
if answer{1} == '1'
    store_mtotalT(filename,399,append(filename,'CAF_coordinates.mat'));
    findRiseFall(2,180,150);
end
end