function Traccia_gruppi_evento(Simili, gruppo, Rows, Columns)   
    [data_x, data_y] = meshgrid(1:Columns, 1:Rows);
    name = append("gruppo", num2str(gruppo));

    figure
    title(name)
    colormap('jet')
    colorbar
    hold on

    for i = 1 : length(fieldnames(Simili.(name)))
        name_evento = append("evento", num2str(i));
        negativi = zeros(0,3);
        positivi = zeros(0,3);
        if Simili.(name).(name_evento).massimi(1,1) ~= 0
            for k = 1 : length(Simili.(name).(name_evento).massimi(:,1))
                x_ref = data_x(Simili.(name).(name_evento).massimi(k,1));
                y_ref = data_y(Simili.(name).(name_evento).massimi(k,1));
                positivi(end+1, :) = [x_ref y_ref i];
            end
        end

        if Simili.(name).(name_evento).minimi(1,1) ~= 0
            for k = 1 : length(Simili.(name).(name_evento).minimi(:,1))
                x_ref = data_x(Simili.(name).(name_evento).minimi(k,1));
                y_ref = data_y(Simili.(name).(name_evento).minimi(k,1));
                negativi(end+1, :) = [x_ref y_ref i];
            end
        end

        z_pos = zeros(length(positivi(:,1)), 1);
        z_pos(1:end, 1) = i;
    
        z_neg = zeros(length(negativi(:,1)), 1);
        z_neg(1:end, 1) = i;

        scatter3(positivi(:,1), positivi(:,2), z_pos, 70, z_pos, 'o', 'filled', 'MarkerEdgeColor', 'black')
        scatter3(negativi(:,1), negativi(:,2), z_neg, 70, z_neg, 'Pentagram', 'filled', 'MarkerEdgeColor', 'black')

    end

    axis equal
    ylim([0 Rows]);
    xlim([0 Columns]);
    xlabel('[n° pixel]');
    ylabel('[n° pixel]');
    hold off
end

