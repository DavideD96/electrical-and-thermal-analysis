function get_store_data_rumore(filename, Nframes, fr_diff, coordname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-15 Last modification: 2024-01-15
%Author: Cristina Zuccali
%get_store_data(filename, fr_end, fr_diff, coordname)
%Return the matrix of frames diff
%
%   'fr_diff' = number of start frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %prendo matrice mtotalT
    [mtotalT] = store_mtotalT_rumore(filename, Nframes, coordname);
    [mtotalDT] = store_mtotalDT_rumore(fr_diff, mtotalT);
end

