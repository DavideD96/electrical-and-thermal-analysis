% Programma per selezionare solo i frame successivi a un evento termico

% Gli faccio fare un ciclo su un array di cartelle così che non lo devo
% fare ogni volta
% Cartelle in cui fare l'analisi
fol = [6];

for i=1:size(fol)
    
    startFolder1 = pwd;
    cd(num2str(fol(i)));

    % Salva la cartella di partenza
    startFolder2 = pwd;  
    
    % Spostati nella sottocartella
    cd('termoFiles_mat');  
    % Carica i dati
    m = load("mtotalT.mat");
    m = m.mtotalT;
    
    % Torna alla cartella di partenza
    cd(startFolder2);
    
    % Numero di frame
    n_frame = size(m, 3);
    
    % Blocco per selezionare la ROI
    imagesc(m(:,:,1010));
    title('set ROI')
    pause;
    %[x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF
    [x,y] = ginput(2); %top left bottom right
    coordinates = [x,y];
    coordinates = [coordinates;x(2),y(2)];
    coordinates(2,:) = [x(2),y(1)];
    coordinates = round(coordinates);
    
    title('set Pixel of Interest')
    pause;
    [x_sing,y_sing] = ginput(1);
    coordinates_sing = round([x_sing,y_sing]);
    
    temp_sing = reshape(m(coordinates_sing(2), coordinates_sing(1), :), [size(m,3), 1]);
    plot(temp_sing);
    title('Andamento della temperatura di 1 pixel');
    
    RoI = m(coordinates(1,2):coordinates(3,2),coordinates(1,1):coordinates(3,1),:);
    
    % Calcola media
    mean_t = zeros(n_frame, 1);
    for i = 1:n_frame
        mean_t(i) = mean(RoI(:, :, i), "all");
    end
    
    % Plotta il grafico
    figure(2);
    plot(mean_t);
    xlabel('Frame');
    ylabel('T media');
    title('Andamento della temperatura', 'FontSize', 13);
    grid on; % Aggiunge la griglia per migliorare la lettura
    
    % Permetti all'utente di selezionare un punto
    disp('Clicca su un punto del grafico per selezionarlo.');
    
    pause;
    
    [x, y] = ginput(1);  % Aspetta la selezione di un punto
    
    % Calcola la distanza tra il punto cliccato e i punti del grafico
    [~, idx] = min(abs((1:n_frame) - x));  % Trova l'indice del punto più vicino
    calamitated_x = idx;                    % Indice calamitato
    calamitated_y = mean_t(calamitated_x);  % Valore corrispondente
    
    % Mostra il punto selezionato nel grafico
    hold on;
    plot(calamitated_x, calamitated_y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    hold off;
    
    % Salva il punto di partenza, setta numero di impulsi, prepara array
    start = calamitated_x;
    n_pulse = 999;
    peaks = zeros(n_pulse, 1);
    
    % Trova i 1000 massimi, in un range da 5 a 20 successivi
    for i = 1:n_pulse
        [~, idx] = max(mean_t(start + 5 : start + 20));  % Restituisce il massimo e il suo indice relativo al sotto-array
        peaks(i) = start + 5 + idx - 1;
        start = peaks(i);
    end
    
    % Plotta il grafico
    figure(2);
    plot(mean_t, '-o');
    xlabel('Frame');
    ylabel('T media');
    title('Andamento della temperatura', 'FontSize', 13);
    grid on; % Aggiunge la griglia per migliorare la lettura
    hold on;
    plot(peaks, mean_t(peaks), 'r*', 'LineWidth', 1.5);
    hold off;
    saveas(figure(2), 'Temperatura media.fig');
    exportgraphics(figure(2), 'Temperatura media.png');
    
    % Matrice ridotta
        m_red = m(:, :, peaks);
        m_red = cat(3, m_red(:,:,1), m_red);
    
    % Matrice ridotta delle differenze
        m_red_diff = diff(m_red, 1, 3);
        m_red_diff = cat(3, m_red_diff(:,:,1), m_red_diff);
    
    % Spostati nella sottocartella
    cd('termoFiles_mat');  
    save('m_red.mat', 'm_red');
    save('m_red_diff.mat', 'm_red_diff');
    % Torna alla cartella di partenza
    cd(startFolder2);
    
    figure(3);
    plot(temp_sing(peaks));
    title('Matrice ridotta: andamento della temperatura di 1 pixel');
    
    figure(4)
    plot(temp_sing);
    title('Andamento della temperatura di 1 pixel');
    hold on;
    plot(peaks, temp_sing(peaks), 'r*', 'LineWidth', 1.5);
    hold off;
    
    % Torna alla cartella di partenza
    cd(startFolder1);

end
