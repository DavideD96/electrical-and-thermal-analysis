function comparison_couple_events( max_peaks, min_peaks, Rows, Columns, grid_draw)
    max_peaks_couple = zeros(0, 4);
    min_peaks_couple = zeros(0, 4);
    
    %seleziona eventi
    n_eventi = 0;
    for i = 1 : length(max_peaks(:,1))
        if max_peaks(i, 1) ~= 0 & max_peaks(i, 2) ~= 0 & min_peaks(i, 1) ~= 0 & min_peaks(i, 2) ~= 0 %verifico se ho un evento coppia
            max_peaks_couple(end+1, :) = max_peaks(i,:);
            min_peaks_couple(end+1, :) = min_peaks(i, :);
            n_eventi = n_eventi + 1;
        end
    end

    %grafico
    figure
    colormap('jet')
    title('Couple events position')
    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    hold on
        if isempty(min_peaks_couple) == 0 
            x_max = data_x(max_peaks_couple(:,1));
            y_max = data_y(max_peaks_couple(:,1));
            z_max = max_peaks_couple(:,3);
            scatter3(x_max,y_max,z_max, 20, z_max, 'o', 'filled', 'MarkerEdgeColor', 'black')
        end

        if isempty(max_peaks_couple) == 0
            x_min = data_x(min_peaks_couple(:,1));
            y_min = data_y(min_peaks_couple(:,1));
            z_min = min_peaks_couple(:,3);
            scatter3(x_min,y_min,z_min,20,z_min, 'Pentagram', 'filled', 'MarkerEdgeColor', 'black')

            if size(z_min) ~= 1
            h_max = surf([x_max(:) x_max(:)],[y_max(:) y_max(:)],[z_max(:) z_max(:)]);
            set(h_max,'facecolor','none','edgecolor','interp');
            set(h_max,'linewidth',1)
            view(2)

            h_min = surf([x_min(:) x_min(:)],[y_min(:) y_min(:)],[z_min(:) z_min(:)]);
            set(h_min,'facecolor','none','edgecolor','interp');
            set(h_min,'linewidth',1)
            end
        end
        

        % text(x_max, y_max, num2str(max_peaks_couple(:, 3)))
        % text(x_min, y_min, num2str(min_peaks_couple(:, 3)))
    
    %griglia
    if grid_draw == 1
        for j = 1:n_eventi
            z_grid = zeros(Rows, Columns);
            z_grid(:,:) = j;
            mesh(z_grid, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'EdgeColor', 'black');
        end
    end
    
    %aggiusto grafico
    n_eventi
        clim([0 n_eventi])
        colorbar
        view(2)
        axis equal
        ylim([0 Rows]);
        xlim([0 Columns]);
        xlabel('[n° pixel]');
        ylabel('[n° pixel]');
    hold off
end

