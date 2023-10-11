function scriptForFit(path, x,y,type)

% last modification 22-03-2019
%
%	scriptForFit(path,analType,data,fitType, disc_cont, nbin)
%
%The function perfom a fit on data and save results
%       path: path where data are saved
%       data: a two column matrix [x,y] for grph fit; a column vector for
%             hist ftit
%       fitType: 
% 
%        'glin': linear fit.
%        'gexp': fit an exponential.
%        'ggss': fit a gaussian.
%        'gbxp': fit a bi-exponential.
%        
%        'hpss': fit a poissonian.
%        'hlgn': fit a lognormal.
%        'hexp': fit an exponential distribution.
%
%In hist case the program display 0 if the null hypotesis has not to be
%rejected, with c.l. = 5%.
%If you choose an option between "hpss", "hlgn" and "hexp" you must put in
%x the centres of the bins, in y the data to histogram.
    
if type == "glin"
    param = fit(x(:,1),y(:,1), 'poly1');
    figure;

    bar(x(:,1),y(:,1));
    hold on;
    plot(param);
    hold off;
        
    CI = confint(param, 0.95);
    data_fit=['coefficiente angolare: ', num2str(param.p1), ', intercetta: ',  num2str(param.p2)];
    data_fit_CI = [data_fit, newline, 'Intervalli di confidenza (95%): ', newline, 'coefficiente angolare: (', num2str(CI(1,1)), ', ', num2str(CI(2,1)), ')', newline, 'intercetta: (', num2str(CI(1,2)), ', ', num2str(CI(2,2)),')'];
    legend('plot dati', data_fit_CI);
    savefig(path);
elseif type == "gexp"
    fitted = fit(x(:,1),y(:,1), 'exp1');
    figure;

    bar(x(:,1),y(:,1));
    hold on;
    plot(fitted);
    hold off;

    CI = confint(fitted, 0.95);
    data_fit=['ampiezza: ', num2str(fitted.a), ' lambda: ', num2str(fitted.b)];
    data_fit_CI = [data_fit, newline, 'Intervalli di confidenza (95%): ', newline, 'ampiezza: (', num2str(CI(1,1)), ', ', num2str(CI(2,1)), ')', newline, 'lambda: (', num2str(CI(1,2)), ', ', num2str(CI(2,2)),')'];
    legend('plot dati', data_fit_CI);
    savefig(path);
elseif type == "ggss"
    fitted = fit(x(:,1),y(:,1), 'gauss1');
    CI = confint(fitted, 0.95);
    figure;

    bar(x(:,1),y(:,1));
    hold on;
    plot(fitted);

    data_fit=['altezza al centro: ', num2str(fitted.a1), ' media: ', num2str(fitted.b1), ' std: ', num2str(fitted.c1/sqrt(2))];
    data_fit_CI = [data_fit, newline, 'Intervalli di confidenza (95%):', newline, 'altezza al centro: (', num2str(CI(1,1)),', ', num2str(CI(2,1)), ') ', newline, 'media: (', num2str(CI(1,2)), ', ', num2str(CI(2,2)), ')', newline,'devst: (', num2str(CI(1,3)/sqrt(2)), ', ', num2str(CI(2,3)/sqrt(2)), ')'];  
    legend('plot dati', data_fit_CI);
    savefig(path);
elseif type == "gbxp"
    fitted = fit(x(:,1),y(:,1), 'exp2');
    bar(x(:,1),y(:,1));
    hold on;
    plot(fitted);
    hold off;
    CI = confint(fitted, 0.95);
    data_fit=['ampiezza1: ', num2str(fitted.a), ' lambda1: ', num2str(fitted.b), newline, 'ampiezza2: ', num2str(fitted.c),' lambda2: ', num2str(fitted.d)];
    data_fit_CI = [data_fit, newline, 'Intervalli di confidenza (95%): ', newline, 'ampiezza1: (', num2str(CI(1,1)), ', ', num2str(CI(2,1)), ')', newline, 'lambda1: (', num2str(CI(1,2)), ', ', num2str(CI(2,2)),')', newline, 'ampiezza2: (', num2str(CI(1,3)), ', ', num2str(CI(2,3)), ')', newline,'lambda2: (', num2str(CI(1,4)), ', ', num2str(CI(2,4)),')' ];
    legend('plot dati', data_fit_CI);
    savefig(path);
end

if type == "hpss"

    %in xy(:,1) ci sono i centri
    
    [N,X] = hist(y(:,1), x(:,1));
    n = double(sum(N));
    pd = fitdist(X,'Poisson','Frequency',N');
    expCounts = n * pdf(pd,X);
    [accept_reject,p,st] = chi2gof(X','Ctrs',X','Frequency',N', 'Expected',expCounts');
    
    %%%%%%%%%%% denormalize %%%%%%%%%%%
    binwidth = X(2,1)-X(1,1);
    area = n * binwidth;
    Y = area * pdf(pd,X(:,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure;
    bar(X,N);%/sum(N));
    hold on;
    plot(X,Y,'LineWidth',2);

    %bar(X,N/sum(N));

    %hold on;
    %poisspdf(X, pd.lambda)
    %plot(X,poisspdf(X, pd.lambda), 'LineWidth',2);
    leg = cell(1,2);
    leg(1,1) = {'Istogramma dati'};
    leg(1,2) = {['Fit:', newline, 'lambda: ', num2str(pd.lambda), newline, 'accept-reject (0,1) = ', num2str(accept_reject) newline, 'Probability = ', num2str(p)]};
    legend(leg);
    hold off;
    savefig(path);

elseif type == "hlgn"

    [N,X] = hist(y(:,1), x(:,1));
    n = double(sum(N));
    pd = fitdist(X,'Lognormal','Frequency',N');
    expCounts = n * pdf(pd,X);
    [accept_reject,p,st] = chi2gof(X','Ctrs',X','Frequency',N', 'Expected',expCounts');
    figure;
    
    %%%%%%%%%%% denormalize %%%%%%%%%%%
    binwidth = X(2,1)-X(1,1);
    area = n * binwidth;
    Y = area * pdf(pd,X(:,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    bar(X,N);%/sum(N));
    hold on;
    plot(X,Y,'LineWidth',2);
    %plot(X,lognpdf(X, pd.mu, pd.sigma), 'LineWidth',2);
    leg = cell(1,2);
    leg(1,1) = {'Istogramma dati'};
    leg(1,2) = {['Fit:', newline, 'media = ', num2str(pd.mu), '  std = ', num2str(pd.sigma), newline, 'accept-reject (0,1) = ', num2str(accept_reject) newline, 'Probability = ', num2str(p)]};
    legend(leg);
    hold off; 
    savefig(path);
elseif type == "hexp"
        
    [N,X] = hist(y(:,1), x(:,1));
    n = double(sum(N));
    pd = fitdist(X,'Exponential','Frequency',N');
    expCounts = n * pdf(pd,X);
    [accept_reject,p,st] = chi2gof(X','Ctrs',X','Frequency',N', 'Expected',expCounts');
    
    %%%%%%%%%%% denormalize %%%%%%%%%%%
    binwidth = X(2,1)-X(1,1);
    area = n * binwidth;
    Y = area * pdf(pd,X(:,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    bar(X,N);%/sum(N));
    hold on;
    plot(X,Y,'LineWidth',2);
    
    %figure;
    %bar(X,N/sum(N));
    %hold on;
    %plot(X,exppdf(X, pd.mu), 'LineWidth',2);
    leg = cell(1,2);
    leg(1,1) = {'Istogramma dati'};
    leg(1,2) = {['Fit:', newline, 'media = ', num2str(pd.mu), newline, 'accept-reject (0,1) = ', num2str(accept_reject), newline, 'Probability = ', num2str(p)]};
    legend(leg);
    hold off; 
    savefig(path);
else
    disp ('Function type unknown, check the sintax.')
    return
        
end
end

