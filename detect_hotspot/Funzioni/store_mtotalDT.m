function [mtotalDT, times, Rows, Columns] = store_mtotalDT()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-15 Last modification: 2024-01-15
%Author: Cristina Zuccali
%   store_mtotalDT(fr_diff, mtotalT)
%
%Return the matrix of frames diff
%
%   'mtotalT': 3D array. mtotalT(:,:,i) is the i-th frame (usually cut
%       accordind to sample shape).
%
%   'fr_diff' = compute temperature difference skipping fr_diff-1 frames
%               OCCHIO che la notazione è diversa da analisi_Nframes013 (in
%               quel caso fr_diff = 2 significa frames consecutivi)
%
%   'mtotalDT' = difference mtotalT(:,:,i+fr_diff+1)-mtotalT(:,:,i). It has
%               dimension length(mtotal(1,1,:))-fr_diff
%   'timesDT' = time istants associated to mtotalDT (length Nframes_tot - fr_diff)
%
% Schematization:
%             fr_diff = 3
%              ________
%             |        |
%             1  2  3  4  5                                N
% mtotal    = |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
%
%                4-1 5-2                              N-(N-3)
% mtotalDT  =     1   2  ...                            N-3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %primo frame differenzaopen pcope
    cd parameters\
        param = load("ThermalParameters.mat");
        param = param.ThermalParameters;
        fr_diff = param.fr_diff;
        freq = param.samplfr;
    cd ..
    cd termoFiles_mat 
    mtotalT = load('mtotalT.mat');
    mtotalT = mtotalT.mtotalT;
    mdiff = mtotalT(:,:, fr_diff + 1) - mtotalT(:,:, 1); %fr_diff = 3 => m(:,:,4)-m(:,:,1), skipping 2,3
    [Rows, Columns] = size(mdiff);
    n_delta_frames = length(mtotalT(1,1,:))-fr_diff; %[1,2,3,4,5,6,7], fr_diff = 3 => [4-1,5-2,6-3,7-4] (length = 7-3)
    mtotalDT = zeros(Rows,Columns, n_delta_frames);
    times = zeros(1, n_delta_frames);
    mtotalDT(:,:,1) = mdiff;
    times(1,1) = (fr_diff) / freq; %campionamento a 30Hz

    %altri
    for i = 2 : n_delta_frames   
        mdiff = mtotalT(:,:, fr_diff + i) - mtotalT(:,:, i);

        mtotalDT(:,:,i) = mdiff;
        times(1,i) = (fr_diff + i-1) / freq; % campionamento a 30Hz
    end

    %salvo matrice
    check = exist('termoFiles_mat','dir');
    if check ~= 7
        mkdir termoFiles_mat;
    end
    
    save("mtotalDT.mat", "mtotalDT");
    save("timesDT", "times")
    cd ..
end

