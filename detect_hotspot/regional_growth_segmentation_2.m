function [im_bin] = regional_growth_segmentation_2(peak, type, im, soglia_perc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-10-26 Last modification: 2023-10-26
%Author: Cristina Zuccali
%regional_growth_segmentation(peak, type, im, soglia_regional)
%
%It makes a test on minima and maxima in a frame: it tests if the peak is
%surrounded by value with the same sign.
%
%   'peak' = is a line vector --> [coordinate, value]
%   'type' = 1 if the peak is a maximum, 0 if the peak is a minimum
%   'im' = array of the value of the considered frame
%   'soglia_perc' = threshold for for pixels selection, percent of high of
%   peak
%
%   im_bin = image obtained with pixels selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %scelta parametri DWT
    %     wname = 'db4';
    %     level =1;
    % 
    % %decomposizione
    %     [C, S] = wavedec2(im, level, wname);
    % 
    % %ricostruzione immagine
    %     im = wrcoef2("a",C,S,wname,level);

    %Coordinate picco e setto im_bin
        [Rows, Columns] = size (im);
        c = ceil(peak(1,1)/Rows); %%floor up
        r = peak(1,1) - Rows*(c-1);

        im_bin = zeros(Rows, Columns);
        im_bin(r,c) = 1;
        soglia_diff = abs(im(r,c))*soglia_perc;

        % str = append('Posizione del massimo:' , num2str(r), ' ', num2str(c));
        % disp(str);
        % im(r,c)

        %riga di zeri per confronto
        zero_row = zeros(1, Columns);

    %y_up
    r_up = 0;
    i = 1;
    for i = 1 : (r-1)
        r_up = r - i;
        status_c = 0;

        j = 1;
            while status_c == 0 && j<=(c-1)
                if abs(im(r,c)) - abs(im(r_up, c-j))  <= soglia_diff
                    im_bin(r_up, c-j) = 1;
                    % status_c
                else
                    status_c = 1;
                end

                j = j+1;
            end
        
        status_c = 0;
        j = c;
            while status_c == 0 && j <= Columns
                if abs(im(r,c)) - abs(im(r_up, j)) <= soglia_diff
                    im_bin(r_up, j) = 1;
                    %status_c
                else
                    status_c = 1;
                end

                j = j + 1; 
            end

        if im_bin(r_up, :) == zero_row
            % str = append('Uscito a: ', num2str(r_up));
            % disp(str);
            break
        end
    end

    %y_down
    i = r;
    r_down = 0;

    for i = r : Rows
        r_down = i;
        status_c = 0;
        j = 1;
            while status_c == 0 && j <= (c-1)
                if abs(im(r,c)) - abs(im(r_down, c-j)) <= soglia_diff
                    im_bin(r_down, c-j) = 1;
                else
                    status_c = 1;
                end

                j = j+1;
            end

        status_c = 0;
        j = c;

            while status_c == 0 && j <= Columns
                if abs(im(r,c)) - abs(im(r_down, j)) <= soglia_diff
                    im_bin(r_down, j) = 1;

                else
                    status_c = 1; 
                end

                j = j + 1;
            end

        if im_bin(r_down, :) == zero_row
            % str = append('Uscito a: ', num2str(r_down));
            % disp(str);
            break
        end
    end
    
    % figure 
    % hold on
    % imagesc(im_bin)
    % colormap('gray')
    % colorbar
    % title('Method: regional growth segmentation, hot regions');
    % hold off
end

