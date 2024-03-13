function histo_ISI_PuntiSimili_001_delenda(intervals1, intervals2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%24/01/2024
%cerca_punti_simili001(massimi, minimi) e associa evento resistivo
%[tempi_simili] = matrice_simili_tempo(Simili, gruppo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice tempi
%    tempi_simili = matrice_simili_tempo003(Simili, 2);

%istogrammi
figure
sgtitle("ISI")
hold on

    h1 = histogram(subplot(2,1,1), intervals1, 'BinWidth', 0.3);
    xlabel('intervalli di tempo [s]');
    ylabel('frequenza');

    % %matrice(:,2) = tempi_simili(:,3);
    % int = ISIpuntiSimili(matrice, 'full');

    h2 = histogram(subplot(2,1,2), intervals2, 'BinWidth', 0.3);

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

    centre_for_fit = center(altezze ~= 0);
    altezze_for_fit = altezze(altezze ~= 0);
    centre_for_fit = centre_for_fit(1:7);
    altezze_for_fit = altezze_for_fit(1:7);
    %lincoeff = polyfit(log10(centre_for_fit(1:5)), log10(altezze_for_fit(1:5)), 1);
    %fit_data = centre_for_fit.^lincoeff(1)*10^lincoeff(2); 
    ft = fittype( 'lambda*exp(-(x*lambda))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.StartPoint = 1;
    [fitresult, gof] = fit( centre_for_fit', altezze_for_fit', ft, opts );
    h = plot( fitresult, center, altezze);
    gof

    ft = fittype( 'A*(x)^(-n)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.StartPoint = [1 2];
    [fitresult, gof] = fit( centre_for_fit', altezze_for_fit', ft, opts );
    h = plot( fitresult, centre_for_fit, altezze_for_fit );
    fit_data = centre_for_fit.^(-fitresult(2))*fitresult(1); 
    loglog(center, altezze);
    hold on
    loglog(centre_for_fit, fit_data);
    hold off
    gof

%     ft = fittype( '(x+x0).^n', 'independent', 'x', 'dependent', 'y' );
%     opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
%     opts.StartPoint = [10 2];
%     opts.Display = 'Off';
% 
% % Fit model to data.
% [fitresult, gof] = fit( centre_for_fit', altezze_for_fit', ft, opts );
% h = plot( fitresult, centre_for_fit, altezze_for_fit );
%hold on
%plot(centre_for_fit,fit_data,'r');

hold off

