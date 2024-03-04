function [media, dev_std] = dev_std_rumore
%ricava la deviazione standard dei pixels per un tempo di nFrames in una
%regione in cui la temperatura dovrebbe rimanere standard
    cd termoFiles_mat 
        mtotalDT = load("mtotalDT_rumore.mat");
        mtotalDT = cell2mat(struct2cell(mtotalDT));
    cd ..
    
    mtotalDT_vector = mtotalDT(:);
    mtotalDT_vector = nonzeros(mtotalDT_vector);
    
    media = mean(mtotalDT_vector);
    dev_std = std(mtotalDT_vector);

    soglia_max = 4*dev_std
    soglia_min = -4*dev_std
end
