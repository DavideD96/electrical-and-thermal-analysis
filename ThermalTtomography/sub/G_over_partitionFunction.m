function G_over_partitionFunction(steps, varargin)

% run this function in "esportazione" folder
% steps: is a row array (e.g. [1,2,3])

num = length(varargin);
IFOV = 5e-5; %serve?

for k = 1:2:num
    if prod(varargin{k}=='_IFOV_')
        IFOV = varargin{k+1}; 
    end
end


cd('Tomography results')
analysis_type = '_mean';

for k = 1:length(steps) 

    cd(num2str(k))
    fname = pwd;
    listing = dir(fname);
    str1 = append(analysis_type,'_Tgroove_a-b_3-6');
    str2 = append(analysis_type,'_Tgroove_b-c_3-8');
    str3 = append(analysis_type,'_Tgroove_c-a_2-8');

    find1_me = strfind(str_complete,str1_me);
    find2_me = strfind(str_complete,str2_me);
    find3_me = strfind(str_complete,str3_me);

    if size(find1_me,1) ~= 0
        step_me_Tgroove1 = load(str_complete);
        step_me_Tgroove1 = step_me_Tgroove1.G_Groove1;
    elseif size(find2_me,1) ~= 0
        step_me_Tgroove2 = load(str_complete);
        step_me_Tgroove2 = step_me_Tgroove2.G_Groove2;
    elseif size(find3_me,1) ~= 0
        step_me_Tgroove3 = load(str_complete);
        step_me_Tgroove3 = step_me_Tgroove3.G_Groove3;
    end

end



end