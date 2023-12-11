function tracepeaks(max_peaks, min_peaks, Rows, Columns, grid_draw)
    %elimino gli zeri da max_peaks e min_peaks
    i = 1;
    max_peaks_clean = max_peaks;
    min_peaks_clean = min_peaks;

    while i <= length(max_peaks_clean(:,1))
        if max_peaks_clean(i,1) ==0 & max_peaks_clean(i,2)==0
            max_peaks_clean(i,:) = [];
            i = i-1;
        end
        i = i+1;
    end
    
    i = 1;
    while i <= length(min_peaks_clean(:,1))
        if min_peaks_clean(i,1) == 0 & min_peaks_clean(i,2) == 0
            min_peaks_clean(i,:) = [];
            i = i-1;
        end
        i = i+1;
    end
    
    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    
    figure
    colormap('jet')
    sgtitle('Events peaks positions')

    subplot(1,2,1)
    hold on
        if isempty(max_peaks_clean) == 0
            cm = colormap(jet);
            numPoints = length(max_peaks_clean(:,1));

            x = data_x(max_peaks_clean(:, 1));
            y = data_y(max_peaks_clean(:, 1));
            z = 1:1:numPoints;
            z = z';
            
            scatter3(x,y,z,20,z,'filled', 'MarkerEdgeColor', 'black')

            h = surf([x(:) x(:)],[y(:) y(:)],[z(:) z(:)]);
            set(h,'facecolor','none','edgecolor','interp');
            set(h,'linewidth',1)

            clim([min(z(:,1)) numPoints])
            colormap(subplot(1,2,1), cm)
            colorbar(subplot(1,2,1))
            view(2)
            %text(x, y, num2str(max_peaks(:, 3)))
        end
        
        if grid_draw == 1 
            for j = 1:length(max_peaks_clean)
                z_grid = zeros(Rows, Columns);
                z_grid(:,:) = j;
                mesh(z_grid, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'EdgeColor', 'black');
            end
        end
        
        axis equal
        ylim([0 Rows]);
        xlim([0 Columns]);
        xlabel('[n° pixel]');
        ylabel('[n° pixel]');
        title('Hot events');
    hold off

    subplot(1,2,2)
    hold on
        if isempty(min_peaks_clean) == 0
            cm = colormap(jet);
            numPoints = length(min_peaks_clean(:,1));

            x = data_x(min_peaks_clean(:, 1));
            y = data_y(min_peaks_clean(:, 1));
            z = 1:1:numPoints;
            z = z';
            
            scatter3(x,y,z,20,z,'filled', 'MarkerEdgeColor', 'black')

            h = surf([x(:) x(:)],[y(:) y(:)],[z(:) z(:)]);
            set(h,'facecolor','none','edgecolor','interp');
            set(h,'linewidth',1)

            clim([min(z(:,1)) numPoints])
            colormap(subplot(1,2,2), cm)
            colorbar(subplot(1,2,2))
            view(2)
            %text(x, y, num2str(min_peaks(:, 3)))
        end
    
        if grid_draw == 1
            for j = 1:length(min_peaks_clean)
                z_grid = zeros(Rows, Columns);
                z_grid(:,:) = j;
                mesh(z_grid, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1, 'EdgeColor', 'black');
            end
        end
        axis equal
        ylim([0 Rows]);
        xlim([0 Columns]);
        xlabel('[n° pixel]');
        ylabel('[n° pixel]');
        title('Cold events');            
    hold off
end

