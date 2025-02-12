function setAndCheck_refPoint2El(filename,frame,reffolder,refname)

% Author: Davide Decastri
%
% This program allows to set a refPoint in a new folder. it also allows to
% move it pixel by pixel to choose the best position. 
% Should be executed after the execution of setInitialRefPoint.m in the 
% reference folder. Using the reference point is it possible to set 
% automatically the position of the CAF and the grooves in the current folder.
%
%   folder: folder containing new data to analyze (you want to set CAF area 
%        on these data, according to a fixed reference).
%   filename: name of the .csv file. INCLUDE frame.
%   frame: integer indicating the frame to analyze
%   reffolder: folder containing the reference data (set before using
%               'setInitialRefPoint.m')
%   refname: main name of reference .csv files (something like 
%           'E26_4Elst_C1_2mm_3-8_IMP1V_f44_-098_')
%
% The program saves:             _
% groove_a-b_3-6_coordinates.mat  |
% groove_b-c_3-8_coordinates.mat  |  all taken from reference!
% groove_c-a_2-8_coordinates.mat _|
% CAF_coordinates.mat
% ref1_coordinates.mat

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

groove1_coord_ = load(append(refname,'groove_coordinates.mat'));
x_groove1 = round(groove1_coord_.groove_coordinates(:,1)); %sdr è CAF
y_groove1 = round(groove1_coord_.groove_coordinates(:,2));
groove_coordinates = [x_groove1, y_groove1];


%optional, for check
m_ = get_data002_matCoord(refname,1,[x_CAF,y_CAF],1);
%m_(x_groove1(1):x_groove1(2),y_groove1(2):y_groove1(3)) = 50;
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(path)

save(append(filename,'groove_coordinates.mat'),'groove_coordinates')

reftrial = append(filename,'ref1_coordinates.mat');
check = exist(reftrial,"file");

%%%%%%%%%%%%%%%%%%%%%%%%% compute coordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m=readtable(sprintf(append(filename,'%d.csv'), frame));
m= m{:,:};
imagesc(m);
pause;
[x,y] = ginput(1);
area_size = [x_CAF(3)-x_CAF(1)+1,y_CAF(3)-y_CAF(1)+1];

answer{1} = 0;
while answer{1} ~= '1'   
    coord_trial = setArea_FromRefPoint([x,y],[x_ref,y_ref],area_size); %x,y are ref point coordinates in the reference of the image
                                                                       %x_ref,y_ref are the coordinates of the refpoint in the reference of CAF             
    coord_trial = round(coord_trial);   % combaciano col frame 1?
    m_trial = get_data002_matCoord(filename,frame,coord_trial,1);
    imagesc(m_trial-m_)
    colorbar
    title('1 + Enter to finish')
    answer = inputdlg({'Move: up-down (8-2), left-right (4-6)'});
    if answer{1} == '8'
        y = y+1;
    elseif answer{1} == '2'
        y = y-1;
    elseif answer{1} == '4'
        x = x-1;
    elseif answer{1} == '6'
        x = x+1;
    end
end

ref_new = [x,y];
% else
%     ref_coord_trial = load(append(filename,num2str(frame),'_ref1_coordinates.mat'));
%     x = ref_coord_trial.ref_new(:,1);
%     y = ref_coord_trial.ref_new(:,2);

coordinates = coord_trial;

save(append(filename,'CAF_coordinates.mat'),'coordinates');
save(append(filename,'ref1_coordinates.mat'),'ref_new');


    %cd ..
    
    colorbar
    
    answer = inputdlg({'store mtotalT (1) or not (0)?'});
    if answer{1} == '1'
        store_mtotalT8cores(filename,499,append(filename,'CAF_coordinates.mat'));
        findRiseFall(2,180,200);
    end
end