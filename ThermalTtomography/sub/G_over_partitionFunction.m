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

allT = zeros(length(steps)*3,1);
allG = zeros(length(steps)*3,1);

for k = 1:length(steps) 

    cd(num2str(k))
    fname = pwd;
    listing = dir(fname); 

    for ii = 1:length(listing)

        str_complete = listing(ii).name;
        str1 = append(analysis_type,'_Tgroove_a-b_3-6');
        str2 = append(analysis_type,'_Tgroove_b-c_3-8');
        str3 = append(analysis_type,'_Tgroove_c-a_2-8');
    
        Gstr1 = append(analysis_type,'_Ggroove_a-b_3-6');
        Gstr2 = append(analysis_type,'_Ggroove_b-c_3-8');
        Gstr3 = append(analysis_type,'_Ggroove_c-a_2-8');
    
        find1_me = strfind(str_complete,str1);
        find2_me = strfind(str_complete,str2);
        find3_me = strfind(str_complete,str3);
    
        find1_Gme = strfind(str_complete,Gstr1);
        find2_Gme = strfind(str_complete,Gstr2);
        find3_Gme = strfind(str_complete,Gstr3);  
    
        if size(find1_me,1) ~= 0
            step_me_Tgroove1 = load(str_complete);
            step_me_Tgroove1 = step_me_Tgroove1.Groove1;
        elseif size(find2_me,1) ~= 0
            step_me_Tgroove2 = load(str_complete);
            step_me_Tgroove2 = step_me_Tgroove2.Groove2;
        elseif size(find3_me,1) ~= 0
            step_me_Tgroove3 = load(str_complete);
            step_me_Tgroove3 = step_me_Tgroove3.Groove3;
        elseif size(find1_Gme,1) ~= 0
            step_Gme_groove1 = load(str_complete);
            step_Gme_groove1 = step_Gme_groove1.G_Groove1;
        elseif size(find2_Gme,1) ~= 0
            step_Gme_groove2 = load(str_complete);
            step_Gme_groove2 = step_Gme_groove2.G_Groove2;
        elseif size(find3_Gme,1) ~= 0
            step_Gme_groove3 = load(str_complete);
            step_Gme_groove3 = step_Gme_groove3.G_Groove3;
        end
    end

    T1_par = sum(step_me_Tgroove1);
    T2_par = sum(step_me_Tgroove2);
    T3_par = sum(step_me_Tgroove3);
    
    G1 = sum(step_Gme_groove1);
    G2 = sum(step_Gme_groove2);
    G3 = sum(step_Gme_groove3);

    allT((k-1)*3+1) = T1_par;
    allT((k-1)*3+2) = T2_par;
    allT((k-1)*3+3) = T3_par;

    allG((k-1)*3+1) = G1;
    allG((k-1)*3+2) = G2;
    allG((k-1)*3+3) = G3;

    cd ..

end

cd ..

figure


plot((allT.^1)./allG) %[G1/T1_par,G2/T2_par,G3/T3_par])

% find best partition function by minimizing the relative std
nhints = 70;
evaluation = zeros(nhints,1);

for k=1:nhints
    hint = (allT.^(k/100))./allG;
    std_hint = std(hint);
    mean_hint = mean(hint);
    std_rel = std_hint/mean_hint;
    evaluation(k,1) = std_rel;
end

plot(evaluation)

[~,best_exponent] = min(evaluation);

plot((allT.^(best_exponent/100))./allG)
title('best exponent = ',num2str(best_exponent))

end