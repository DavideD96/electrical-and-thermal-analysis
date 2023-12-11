function plotTvsA(max_peaks, min_peaks, T_max, T_min, area_max, area_min)
    figure
    sgtitle('T vs A')
    
    for i = 1: length(max_peaks(:,1))
        subplot(2,1,1)
        hold on
            if(max_peaks(i,1) ~=0 & max_peaks(i,2)~=0)
                plot(T_max(max_peaks(i, 4)), area_max(max_peaks(i, 4)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
            end
            xlabel('Temperature difference [°C]');
            ylabel('Area [#pixels]');
            title('Positive events');
        hold off
        
        subplot(2,1,2)
        hold on
            if(min_peaks(i,1) ~=0 & min_peaks(i,2)~=0)
                plot(T_min(min_peaks(i, 4)), area_min(min_peaks(i, 4)), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');

            end
            xlabel('Temperature difference [°C]');
            ylabel('Area [#pixels]');
            title('"Negative events');
        hold off
    end
end

