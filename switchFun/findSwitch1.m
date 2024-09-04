function switchFound = findSwitch1(matr,sigMatr, col, ns, method, sel, selectOrNot, folder,RoG, varargin)

%Date: 2019-02-18 Last Modification: 2019-06-27
%Author: M. Camponovo, D. Decastri, M. Mirigliano
%
%	switchFound = findSwitch(matr,sigMatr,col,ns,method,sel)
%
%Dependencies: findswitch_rel, find_regimes, IntervalsAnalysis,
%              fromFemH1ToEconometricOutlier
%
%The program perform a analysis to collect the switching events on quantity
%in matr(:,col); matr has to have a umber of column greater or equal to
%two; the results are saved in the matrix switchFound where one coulmn of 0
%and 1 is added at the input matrix (1 is a switch event)
%
%   matr: the matrix of interest where the coumn are the quantities to be
%         analyzed
%   sigMatr: the matrix of interval and correspondant sigma for the
%            quantity of interest (see findSwitch_rel)
%   col: the column of the quantity to be analyzed
%   ns: the number of sigmas to collect switch events (see findSwitch_rel)
%   method: a three charachter vector; select the method to perform the analysis
%           'rel' use the relative method (see findSwitch_rel)
%           'sig' compute sigma on different intervals of your data
%           'ecn' use econometric tools
%           'usr' the user specify a mean and a sigma in varargin
%   sel: if true: you can select an interval from the whole data vector
%        if auto: an input dialog window is opened and the desired voltage
%        value can be selected
%   vararing: 
%            you can specify two value in varargin, a mean in the first
%            position and a sigma in the second. These values are used with
%            the method 'usr'.
%

%if sel = true, you select the interval of interest
if sel==true
    figure;
    subplot(2,1,2);
    plot(matr(:,1)-matr(1,1),matr(:,2))         % I add the voltage column; ATTENTION
    subplot(2,1,1);
    plot(matr(:,1)-matr(1,1),matr(:,end))
    title('Press any key and then select the tow points for boundary interval on x axis');
    
    pause;
    [x1,y1] = ginput(1)
    [x2,y2] = ginput(1)
    if x2<x1
        [t,v1,v2] = extract_p(matr(:,1)-matr(1,1),x2,x1);
    else
        [t,v1,v2] = extract_p(matr(:,1)-matr(1,1),x1,x2);
    end
    matr = matr(v1:v2,:);
elseif prod(sel=='auto')
    answer = inputdlg({'Enter the value of the voltage.'});
    voltageSelected = str2num(answer{1});
    ind = find(abs(matr(:,2)-voltageSelected) < 0.001);
    matr = matr(ind,:);
end

%performed the analysis through the desired method
if prod(method == 'rel')
    switchFound = findSwitch_rel2(matr,col,sigMatr,ns,true);
elseif prod(method == 'adp')
    answer = inputdlg({'Enter the maximum number of clusters to search.'});
    results = find_regimes(matr(:,col), str2num(answer{1}), [],[], true);
    %----analysis of each intrval----
    datiAnalizzati = cell(results(1).nIntervals,1);
    cellMeanSigmas = cell(results(1).nIntervals,2); %k, means (vett), sigmas (vett)
    
    for g = 1:results(1).nIntervals
        %cellMeanSigmas{g,1} = results(g).optimal_k;
        cellMeanSigmas{g,2} = [results(g).centroids, results(g).sigmas];
        cellMeanSigmas{g,2}  = sortrows(cellMeanSigmas{g,2}, 1, 'descend'); %ordino per medie decrescenti
    end
    
    for h = 1:results(1).nIntervals
        datiAnalizzati{h,1} = findSwitch_rel2(matr(((h-1)*200+1):h*200,:), col, cellMeanSigmas{h,2}, ns,false);
    end
    
    switchFound = vertcat(datiAnalizzati{:,1});
    %normalization
    switchFound(:,1) = switchFound(:,1) - switchFound(1,1);    
    figure;
    plot(matr(:,1)-matr(1,1),matr(:,col));
    hold on;
    for d = 1:size(switchFound,1)
        if switchFound(d,5) == 1
            plot(switchFound(d:d+1,1),switchFound(d:d+1,col), 'ro');
        end
    end
    hold off;
    
elseif prod(method == 'sig')

    matMeanSig = IntervalsAnalysis1(matr(:,1),matr(:,col), selectOrNot, folder); 
    switchFound = findSwitch_rel2(matr,col,matMeanSig,ns,true,RoG,1);
    dlmwrite('sigmaLevel.txt',matMeanSig,'delimiter','\t')
      
elseif prod(method == 'usr')
    
    sigMatr = [varargin{1}, varargin{2}];
    if varargin{2} == 0
        disp('Error: invalid input.');
        return;
    end
    switchFound = findSwitch_rel1(matr,col,sigMatr,ns,true);
else
    disp('Incorrect method; please see help. Bye bye')
    switchFound = 0;
end

%------------------ tolgo i -1 ---------------------
%switchFound(switchFound(:,end) == -1,end) = 0;
%---------------------------------------------------

end