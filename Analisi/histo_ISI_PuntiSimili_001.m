function histo_ISI_PuntiSimili_001(Simili)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%24/01/2024
%cerca_punti_simili001(massimi, minimi) e associa evento resistivo
%[tempi_simili] = matrice_simili_tempo(Simili, gruppo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice tempi
    tempi_simili = matrice_simili_tempo003(Simili, 2);

%istogrammi
figure
sgtitle("ISI")
hold on

    matrice(:,1) = tempi_simili(:,1);
    matrice(:,2) = tempi_simili(:,2);

    int = ISIpuntiSimili(matrice, 'full');
    % histogram(subplot(n_gruppi,1,i-1), int, 'BinMethod','fd');
    h1 = histogram(subplot(2,1,1), int, 'BinWidth', 0.3);
    xlabel('intervalli di tempo [s]');
    ylabel('frequenza');

    matrice(:,2) = tempi_simili(:,3);
    int = ISIpuntiSimili(matrice, 'full');

    h2 = histogram(subplot(2,1,2), int, 'BinWidth', 0.3);

    xlabel('tempo [s]');
    ylabel('frequenza');

hold off

figure

hold on

    center = h1.BinEdges(2:end) - h1.BinWidth/2;
    altezze = h1.BinCounts;
    loglog(subplot(2,1,1), center, altezze, '-o', 'MarkerFaceColor', 'blue');
    title('Analisi ISI (gruppo 1)')
    xlabel('tempo [s]');
    ylabel('frequenza');

    center = h2.BinEdges(2:end) - h2.BinWidth/2;
    altezze = h2.BinCounts;
    loglog(subplot(2,1,2), center, altezze, '-o', 'MarkerFaceColor', 'blue');
    title('Analisi ISI (gruppo 2)')
    xlabel('tempo [s]');
    ylabel('frequenza');

hold off

