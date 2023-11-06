function [r_cm, c_cm] = calculate_CM(imm, Rows, Columns)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-06 Last modification: 2023-11-06
%Author: Cristina Zuccali
%calculate_CM(imm, dec_centroid)
%
%It calculates the coordinates of the CM of the image.
%   imm = matrix of the frame;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    somma_pesata_r = 0;
    somma_pesata_c = 0;
    peso = 0;

    for r = 1 : Rows
        for c = 1 : Columns
            somma_pesata_r = somma_pesata_r + r * abs(imm(r, c));
            somma_pesata_c = somma_pesata_c + c * abs(imm(r, c));

            peso = peso + abs(imm(r, c));    
        end
    end

    r_cm = somma_pesata_r/peso;
    c_cm = somma_pesata_c/peso;
end

