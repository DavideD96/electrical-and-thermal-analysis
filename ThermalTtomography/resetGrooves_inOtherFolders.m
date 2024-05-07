function resetGrooves_inOtherFolders(filename,reffolder,refname)

% Author: Davide Decastri
%
% This program reset grooves coordinates.
%
%   filename: name of the .csv file. INCLUDE frame.
%   reffolder: folder containing the reference data (set before using
%               'setInitialRefPoint.m')
%   refname: main name of reference .csv files (something like 
%           'E26_4Elst_C1_2mm_3-8_IMP1V_f44_-098_')

path = pwd;
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%% references %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(reffolder)

CAF_coord = load(append(refname,'CAF_coordinates.mat'));
x_CAF = CAF_coord.coordinates(:,1); %sdr è immagine totale
y_CAF = CAF_coord.coordinates(:,2);

ref_coord_ = load(append(refname,'ref1_coordinates.mat'));
x_ref = ref_coord_.ref_coordinates(1,1); %sdr è immagine totale
y_ref = ref_coord_.ref_coordinates(1,2);

x_ref = x_ref - x_CAF(1,1) + 1; %sdr ora è CAF
y_ref = y_ref - y_CAF(1,1) + 1;

groove1_coord_ = load(append(refname,'groove_a-b_3-6_coordinates.mat'));
x_groove1 = round(groove1_coord_.groove1_coordinates(:,1)); %sdr è CAF
y_groove1 = round(groove1_coord_.groove1_coordinates(:,2));
groove1_coordinates = [x_groove1, y_groove1];

groove2_coord_ = load(append(refname,'groove_b-c_3-8_coordinates.mat'));
x_groove2 = groove2_coord_.groove2_coordinates(:,1);
y_groove2 = groove2_coord_.groove2_coordinates(:,2);
groove2_coordinates = [x_groove2, y_groove2];


groove3_coord_ = load(append(refname,'groove_c-a_2-8_coordinates.mat'));
x_groove3 = groove3_coord_.groove3_coordinates(:,1);
y_groove3 = groove3_coord_.groove3_coordinates(:,2);
groove3_coordinates = [x_groove3, y_groove3];

%optional, for check
m_ = get_data002_matCoord(refname,1,[x_CAF,y_CAF],1);
%m_(x_groove1(1):x_groove1(2),y_groove1(2):y_groove1(3)) = 50;
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(path)

save(append(filename,'groove_a-b_3-6_coordinates.mat'),'groove1_coordinates')
save(append(filename,'groove_b-c_3-8_coordinates.mat'),'groove2_coordinates')
save(append(filename,'groove_c-a_2-8_coordinates.mat'),'groove3_coordinates')

end