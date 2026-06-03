function resetXAxisToZero()

    ax = gca;

    % Limiti correnti dell'asse x
    xl = xlim(ax);

    % Tick correnti
    xt = xticks(ax);

    % Valori relativi allo zero locale
    rel_xt = xt - xl(1);

    % Disattiva la notazione esponenziale
    ax.XAxis.Exponent = 0;

    % Crea etichette in formato normale
    labels = arrayfun(@(x) sprintf('%.15g', x), rel_xt, ...
                      'UniformOutput', false);

    % Applica le etichette
    xticklabels(ax, labels);

end