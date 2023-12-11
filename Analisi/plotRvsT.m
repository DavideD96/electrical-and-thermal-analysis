function plotRvsT(delta_t, resistance, El_rs_, max_peaks, min_peaks)
    resistance_events = [resistance, El_rs_(:, end-1)];
    [eventi_pos, eventi_neg] = cerca_evento_termo_004(max_peaks, min_peaks, resistance_events, delta_t);
    %save('switch.mat', 'resistance')
    figure
    sgtitle('R vs T')

    subplot(2,1,1)
    hold on
    if isempty(eventi_pos) == 0
        plot(eventi_pos(:,1), eventi_pos(:,2), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    end
    xlabel('Resistence difference [Ohm]');
    ylabel('Temperature difference [°C]');
    title('Positive events');
    hold off

    subplot(2,1,2)
    hold on
    if isempty(eventi_neg) == 0
        plot(eventi_neg(:,1), eventi_neg(:,2), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
    end
    xlabel('Resistence difference [Ohm]');
    ylabel('Temperature difference [°C]');
    title('Negative events');
    hold off
end

