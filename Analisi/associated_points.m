function associated_points(peaks_1,peaks_2, Rows, Columns, grid_draw)
%peaks1: punti di riferimento
    max_peaks_couple = zeros(0, 4);
    min_peaks_couple = zeros(0, 4);
    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    %seleziona coppie
    for i = 1 : length(peaks_1(:,1))
        if peaks_1(i, 1) ~= 0 & peaks_1(i, 2) ~= 0 & peaks_2(i, 1) ~= 0 & peaks_2(i, 2) ~= 0 %verifico se ho un evento coppia
            max_peaks_couple(end+1, :) = peaks_1(i,:);
            min_peaks_couple(end+1, :) = peaks_2(i, :);
        end
    end
    
    %seleziona punti
    max_restanti = max_peaks_couple;
    min_restanti = min_peaks_couple;

    figure
    colormap('jet')
    title('Confronto tra punto caldo e punti freddi associati')

    j = 1;
    
    hold on
    while j <= length(max_restanti(:,1))
        max_ragg = zeros(0, 4);
        min_ragg = zeros(0, 4);
    
        max_ragg(1, :) = max_restanti(1, :);
        min_ragg(1, :) = min_restanti(1, :);
        
        max_restanti(1, :) = [];
        min_restanti(1, :) = [];
        
        i = 1;
        while i <= length(max_restanti(:,1))
            state = raggruppo_2eventi(max_ragg(1,1), max_ragg(1, 2), max_restanti(i, 1), max_restanti(i, 2), Rows, Columns);
    
            if state == 1
                max_ragg(end+1, :) = max_restanti(i, :);
                min_ragg(end+1, :) = min_restanti(i, :);
    
                max_restanti(i, :) = [];
                min_restanti(i, :) = [];
    
                i = i-1;
            end
            i = i+1;
        end

        x_max = data_x(max_ragg(:,1));
        y_max = data_y(max_ragg(:,1));
        
        x_min = data_x(min_ragg(:,1));
        y_min = data_y(min_ragg(:,1));

        z = zeros(length(min_ragg(:,1)), 1);
        z(1:end, 1) = j;

        scatter3(x_max, y_max, z, 70, z, 'o', 'filled', 'MarkerEdgeColor', 'black')
        scatter3(x_min, y_min, z, 70, z, 'Pentagram', 'filled', 'MarkerEdgeColor', 'black')
        
        str = append('#max=', num2str(length(max_ragg(:,1))), newline,'#min=', num2str(length(min_ragg(:,1))));
        text(x_max(1,1), y_max(1,1), z(1,1), str)
        
        if grid_draw == 1
            z_grid = zeros(Rows, Columns);
            z_grid(:,:) = j;
            mesh(z_grid, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'EdgeColor', 'black');
        end
        
        clim([0 j])
        colorbar
        view(2)
        j = j+1;
    end
    axis equal
    ylim([0 Rows]);
    xlim([0 Columns]);
    xlabel('[n° pixel]');
    ylabel('[n° pixel]');
    hold off
end

