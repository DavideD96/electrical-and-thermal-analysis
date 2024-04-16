function setAndCheck_refPoint(filename,frame,coordname,refname)

CAF_coord = load(coordname);
x_CAF = CAF_coord.coordinates(:,1);
y_CAF = CAF_coord.coordinates(:,2);

ref_coord_ = load(refname);
x_ref = ref_coord_.ref_coordinates(1,1);
y_ref = ref_coord_.ref_coordinates(1,2);

% compute coordinates
m=readtable(sprintf(append(filename,'%d.csv'),1));
m= m{:,:};
imagesc(m);
pause;
[x,y] = ginput(1);

% coordname = cellstr(coordname);
% coordname = coordname{1};
% 
% isa(coordname,'string')

area_size  = [x_CAF(3)-x_CAF(1)+1,y_CAF(3)-y_CAF(1)+1]

coord_trial = setArea_FromRefPoint([x,y],[x_ref,y_ref],area_size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% combaciano col frame 1?

m_trial = get_data002_matCoord(filename,frame,coord_trial,1);
m = get_data002_matCoord(filename,1,coord_trial,1);

imagesc(m_trial-m)
end