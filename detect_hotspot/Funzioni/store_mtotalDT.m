function [mtotalDT, times, Rows, Columns] = store_mtotalDT(fr_diff, mtotalT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-15 Last modification: 2024-01-15
%Author: Cristina Zuccali
%store_mtotalDT(fr_diff)
%Return the matrix of frames diff
%
%   'fr_diff' = number of start frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %primo frame differenza
    mdiff = mtotalT(:,:, fr_diff + 1) - mtotalT(:,:, 1);
    [Rows, Columns] = size(mdiff);
    n_delta_frames = length(mtotalT(1,1,:))-fr_diff;
    mtotalDT = zeros(Rows,Columns, n_delta_frames);
    times = zeros(1, n_delta_frames);

    mtotalDT(:,:,1) = mdiff;
    times(1,1) = (fr_diff)/30; %campionamento a 30Hz

    %altri
    for i = 2 : n_delta_frames   
        mdiff = mtotalT(:,:, fr_diff + i) - mtotalT(:,:, i);

        mtotalDT(:,:,i) = mdiff;
        times(1,i) = (fr_diff + i-1) / 30; % campionamento a 30Hz
    end

    %salvo matrice
    check = exist('termoFiles_mat','dir');
    if check ~= 7
        mkdir termoFiles_mat;
    end
    cd termoFiles_mat 
    save("mtotalDT.mat", "mtotalDT");
    save("timesDT", "times")
    cd ..
end

