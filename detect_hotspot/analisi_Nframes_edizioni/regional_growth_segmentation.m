function [im_bin] = regional_growth_segmentation(peak, type, im, soglia_perc)
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
    %Coordinate picco e setto im_bin
        [Rows, Columns] = size (im);
        c = ceil(peak(1,1)/Rows); %%floor up
        r = peak(1,1) - Rows*(c-1);

        im_bin = zeros(Rows, Columns);
        im_bin(r,c) = 1;
        soglia_diff = abs(im(r,c))*soglia_perc;

    %y_up
    status_r = 0;
    i = 1;
    while status_r ~= c && i <= (r-1)
        status_r = 0;
        r_up = r - i;
        status_c = 1;

        j = 1;
            while status_c == 0 && j<=(c-1)
                if abs(im(r,c)) - abs(im(r_up, c-j))  <= soglia_diff
                    im_bin(r_up, c-j) = 1;

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

                else
                    status_c = 1;
                    status_r = j;
                end

                j = j + 1; 
            end
        i = i + 1;
    end

    %y_down
    status_r= 0;
    i = r;
    while status_r ~=c && i <= Rows
        status_r = 0;
        r_down = i;
        status_c = 0;
        j = 1;
            while status_c == 0 && j <= (c-1)
                if abs(im(r,c)) - abs(im(r_down, c-j))<= soglia_diff
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
                    status_r = j;
                end

                j = j + 1;
            end
        i = i+1;
    end
    
    % figure 
    % hold on
    % imagesc(im_bin)
    % colormap('gray')
    % colorbar
    % title('Method: regional growth segmentation, hot regions');
    % plot(r, c, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'black'); 
    % hold off
end

