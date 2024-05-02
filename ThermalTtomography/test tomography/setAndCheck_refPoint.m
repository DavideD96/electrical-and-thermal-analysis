function setAndCheck_refPoint(filename,frame,reffolder,refname)

% Author: Davide Decastri
%
% This program allows to set a refPoint in a new folder. Should be executed
% after the execution of setInitialRefPoint.m in the reference folder.
% Using the reference point is it possible to set automatically the
% position of the CAF and the grooves.
%
%   folder: folder containing new data to analyze (you want to set CAF area 
%        on these data, according to a fixed reference).
%   filename: name of the .csv file
%   frame: integer indicating the frame to analyze
%   reffolder: folder containing the reference data (set before using
%               'setInitialRefPoint.m')
%   refname: main name of reference .csv files (something like 
%           'E26_4Elst_C1_2mm_3-8_IMP1V_f44_-098_')

path = pwd;
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%% references %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(reffolder)

CAF_coord = load(append(refname,'_CAF_coordinates.mat'));
x_CAF = CAF_coord.CAF_coordinates(:,1); %sdr è immagine totale
y_CAF = CAF_coord.CAF_coordinates(:,2);

ref_coord_ = load(append(refname,'_ref1_coordinates.mat'));
x_ref = ref_coord_.ref_coordinates(1,1); %sdr è immagine totale
y_ref = ref_coord_.ref_coordinates(1,2);

x_ref = x_ref - x_CAF(1,1) + 1; %sdr ora è CAF
y_ref = y_ref - y_CAF(1,1) + 1;

groove1_coord_ = load(append(refname,'_groove_a-b_3-6_coordinates.mat'));
x_groove1 = round(groove1_coord_.groove1_coordinates(:,1)); %sdr è CAF
y_groove1 = round(groove1_coord_.groove1_coordinates(:,2));

groove2_coord_ = load(append(refname,'_groove_b-c_3-8_coordinates.mat'));
x_groove2 = groove2_coord_.groove2_coordinates(:,1);
y_groove2 = groove2_coord_.groove2_coordinates(:,2);

groove3_coord_ = load(append(refname,'_groove_c-a_2-8_coordinates.mat'));
x_groove3 = groove3_coord_.groove3_coordinates(:,1);
y_groove3 = groove3_coord_.groove3_coordinates(:,2);

%optional, for check
m_ = get_data002_matCoord(refname,1,[x_CAF,y_CAF],1);
%m_(x_groove1(1):x_groove1(2),y_groove1(2):y_groove1(3)) = 50;
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(path)

reftrial = append(filename,num2str(frame),'_ref1_coordinates.mat');
check = exist(reftrial,"file");

%%%%%%%%%%%%%%%%%%%%%%%%% compute coordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if check == 0
    m=readtable(append(filename,'.csv'));
    m= m{:,:};
    imagesc(m);
    pause;
    [x,y] = ginput(1);
    ref_new = [x,y];
    area_size = [x_CAF(3)-x_CAF(1)+1,y_CAF(3)-y_CAF(1)+1];
    
    x
    y
    x_ref
    y_ref
    answer{1} = 0;
    while answer{1} ~= '1'   
    

        coord_trial = setArea_FromRefPoint([x,y],[x_ref,y_ref],area_size); %x,y are ref point coordinates in the reference of the image
                                                                           %x_ref,y_ref are the coordinates of the refpoint in the reference of CAF             
        coord_trial
                                                                          % combaciano col frame 1?
        m_trial = get_data002_matCoord(filename,frame,coord_trial,1);
        imagesc(m_trial-m_)
        colorbar
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
% else
%     ref_coord_trial = load(append(filename,num2str(frame),'_ref1_coordinates.mat'));
%     x = ref_coord_trial.ref_new(:,1);
%     y = ref_coord_trial.ref_new(:,2);
    save(append(filename,num2str(frame),'_ref1_coordinates.mat'),'ref_new');
end

% coordname = cellstr(coordname);
% coordname = coordname{1};
% 
% isa(coordname,'string')

%%%%%%%%%%%%%%%%%%%%%%% Set CAF area, grooves %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cd ..

colorbar
end