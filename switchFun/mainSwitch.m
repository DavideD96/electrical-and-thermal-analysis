function s = mainSwitch(nomefile,folder,method,varargin)
%
%Date: 2019-02-18 Last Modification: 2023-11-14
%Author: M. Camponovo, D. Decastri, M. Mirigliano
%
%   mainSwitch(nomefile,folder,method,sel,'OPT',VALUE)
%
%Dependencis: findSwitch, ISI, scriptForFit, numberPerBin, autocorrelations
%             detrend_, burstSelector, IEI, numberPerBinInsideBursts,
%             gridxy, countDeltaT
%
%The main to analyze the switch data; a file named 'sigmaLevel.txt' where
%the values of sigma and quantity discriminants are written has to be found
%in the current folder. The analysis to be performed on the data can be
%selected from 'option' variable.
%
%   'nomefile': the name of the file where data are saved (usually
%               'Data.mat'). The name of the data in the workspace must be
%               'R'.
%   'folder': the name of the folder in the current directory where the
%             the file containing interval parameters is to be found (see
%             'sig' method).
%   'method': method to be used to find the switch events
%       'rel' - reltive differance between two contigues points; when 'rel'
%               is invoked, 'col' and 'nos' have to be specifed (SEE
%               'OPT'). (RECOMMENDED)
%       'adp' - if you choose this method, you must enter the value 4 (resistance) in 
%               the variable 'col'. The program find an optimal number of
%               clusters for the values of the resistance, in time
%               intervals containing 200 points. Is computed the mean and
%               the sigma for each cluster, and then the method 'rel' is
%               used.
%       'sig' - this method allow you to choose manually an interval of the time
%               serie for computing a mea and a sigma. Then, the method
%               'rel' is used. (RECOMMENDED) You can decide to choose the
%               interval manually at the beginning of the analysis. The
%               
%       'ecn' - use an hibrid method: the program identyfy the clusters of 
%               hte values of resistance using the same algorithm of the
%               method 'apd', and then use an econometric method to find
%               the switches inside the clusters. The the passages of the
%               resistance from a cluster to another is considered a
%               switch.
%       'usr' - the user specify a mean and a sigma, and then the method
%               'rel' is used.
%   'appl': specify if you are applying constant voltage ('volt') or
%           current ('curr').
%   'sel': sel is true if you ewant to select a data interval, false
%          otherwise
%   'ntv': select intervals to compute mean and std.
%   'OPT': an array of three charachters that define the meaning of value
%       'col' - VALUE spcifies the index of the column to be analyzed
%       'nos' - VALUE is the number of sigma to recognize swithing events
%       'bin' - VALUE of bin length (in seconds)
%       'fit' - VALUE 0 (default value) or 1; 0 no fit is performed, 1 a
%               dialog box apperas to ask the user fit parameter
%       'lgs' - number of lags for the autocorrelation and partial
%               autocorrelation.
%       'mea' - mean, to be used with the method 'usr'.
%       'sgm' - sigma, to be used with the method 'usr'.
%       'dlt' - time interval for the "cdt" analysis.
%       'evt' - time interval for the IEI analysis (in s)
%       'opt' - if 'opt' is specified VALUE is a string array defined between 
%               double quotes that defines the operations to be operformed               
%               "numBin" - compute the number of switch in an interval
%                          defined by bin length option (see 'bin') 
%               "ISI"    - compute the Inter-Switch-Interval
%               "timeCorr" - compute the FTT, the power spectral density,
%                          the autocorrelation function, the partial autocorrelation
%                          function and also return in s.lbqt the result about the
%                          correlation given by the Ljung-Box Q test.
%               "IEI" - comupute the Inter Event Interval asking the maximum distance
%                       between consecutive switches inside the same burst.
%               "bNb" - compute the "numBin" analysis inside the bursts,
%                       using the binlength specified by the input 'bin'.
%               "cdt" - compute the Barabàsi et al. analysis for the
%                       correlation between the switches. To simulate the
%                       stochastic beaviour, the switches are mixed ten times
%                       and then is taken a mean of the histograms
%                       resulting from the analysis of each 'mix'.
%

%define default variable;
nos = 4;
col = 2;
ft = 0;
bl = 2;
deltaT = 1;
timeLength = 1;
nlags = 30;
meanByUser = 0;
sigmaByUser = 0;
i = 0; %index to take account of the number of otpions to be performed

R = load(nomefile).R;

%set the data in varargin
num = length(varargin);
if num < 1
    disp('Insert the options please');
    return
elseif rem(num,2)~=0
    disp('ATTENTION: one of the options misses its VALUE')
    return;
else
    for k = 1:2:num
        if prod(varargin{k}=='col')
            col = varargin{k+1};
        elseif prod(varargin{k}=='nos')
            nos = varargin{k+1};
        elseif prod(varargin{k}=='bin')
            bl = varargin{k+1};
        elseif prod(varargin{k}=='fit')
            ft = varargin{k+1};
        elseif prod(varargin{k}=='lgs')
            nlags = varargin{k+1};
        elseif prod(varargin{k}=='mea')
            meanByUser = varargin{k+1};
        elseif prod(varargin{k}=='sgm')
            sigmaByUser = varargin{k+1};
        elseif prod(varargin{k}=='dlt')
            deltaT = varargin{k+1};
        elseif prod(varargin{k}=='evt')
            timeLength = varargin{k+1};
        elseif prod(varargin{k}=='nvt')
            selOrNot = varargin{k+1};
        elseif prod(varargin{k}=='opt')
            i = i + 1;
            opt(i) = varargin{k+1};
        end
    end
end


voltage = R(:,2);
I = R(:,3);

Resistance = voltage./I;
R = [R(:,1:3), Resistance];
sigLev = 1; %%cafone

%--------------FIND SWITCH--------------
anlR = findSwitch1(R,sigLev,col, nos, method, false, selOrNot, folder);
%---------------------------------------

s.detection = [anlR()];

numberofSwitches = sum(anlR(:,end));

s.nsw = numberofSwitches;

for j = 1:i
    if opt(j) == "ISI"
        
        %-----build the path to save without ext----
        build_path = [path,'\ISI_V',num2str(anlR(1,2)),'_sig',num2str(nos)]; 
        %control the number of switch
        if numberofSwitches == 0
            disp('No switch found, you cannot use ISI! Bye bye');
            return;
        end
        %run ISI
        v = ISI(anlR, 'full');
        %-------------------------------
        
        show = figure;
        tmpBin = round(anlR(end,1)/(20*(anlR(2,1)-anlR(1,1)))); %choose the bin number
        histogram(v,tmpBin);
        txt = ['Temporary bin: ',num2str(tmpBin), newline...
            ,'Inserire numero di bin per ISI. Inserire 0 se si vuole usare la Freedmann-Diaconis rule.'];
        answer = inputdlg({txt});
        close(show);
        numBin = str2num(answer{1});
        if numBin == 0
            [N, edg] = histcounts(v, 'BinMethod','fd');                
        else
            [N, edg] = histcounts(v,numBin);
        end
        
        switch ft
            case 1
                answer = inputdlg({'Enter the type of fit for ISI (hexp, hlgn)'});
                if answer{1} == "hlgn"
                    fitType = 'LGN';
                elseif answer{1} == "hexp"
                    fitType = 'EXP';
                end
                %----centers computation----
                centri = zeros(size(edg,2)-1,1);
                for i = 1:size(edg,2)-1
                    centri(i,1) = edg(1,i) + (edg(1,i+1)-edg(1,i))/2;
                end
                %---------------------------                
                scriptForFit([build_path,'FIT.fig'],centri,v,answer{1});
            case 0                
                figure;
                histogram('BinEdges',edg, 'BinCounts',N,'Normalization','probability'); %normlalization NameValue added
                title ('ISI');  
                savefig([build_path,'.fig']);
        end
        s.isi = v;
        
    elseif opt(j) == "numBin"
        %-----build the path to save without ext----
        build_path = [path,'\BIN_V',num2str(anlR(1,2)),'_sig',num2str(nos),'_tm',erase(num2str(bl),'.'),'_method',method];
        %control the number of switch
        if numberofSwitches == 0
            disp('No switch found, you cannot use numberPerBin! Bye bye');
            return;
        end
        %run ISI
        colB = size(anlR,2);       
        v = numberPerBin(anlR,1,colB,bl);
        %-------------------------------
        
        switch ft
            case 1
                show = figure;
                histogram(v(:,3));
                answer = inputdlg({'Enter the type of fit for number per bin (hpss-poisson or hlgn-lognormal)'});
                close(show);
                
                %----carico centri----               
                if answer{1} == "hlgn"
                    fitType = 'LGN';
                    M = max(v(:,3));
                    edg = 1:M;
                    v = v(v(:,3)~=0,:); 
                elseif answer{1} == "hpss"
                    fitType = 'PSS';
                    M = max(v(:,3));
                    edg = 0:M;
                elseif answer{1} == "hexp"
                    fitType = 'EXP';
                    M = max(v(:,3));
                    edg = 0:M;
                end                
                %---------------------
                scriptForFit([build_path,'/FIT_BIN_',fitType,'.fig'],edg', v(:,3),answer{1});               
            case 0              
                M = max(v(:,3));
                edg = 0:M;
                figure;
                [N,X]=hist(v(:,3),edg);
           
                bar(X,N/sum(N)); %prima plot
                title ('SwitchPerBin'); 
                savefig([build_path,'.fig']);    
        end
        s.nXb = v;
        
    elseif opt(j) == "timeCorr"
        %{
        %----analysis performed on column defined by 'col'----        
        [residuals, degree] = detrend_(anlR(:,1),anlR(:,col));        
        %----compute delay----
        interv = diff(anlR(:,1));
        delay = mean(interv);
        %run autocorrelations NOTA: 'path' is the argument, not 'build_path'
         %}
        %autocorrelazioni = autocorrelations(residuals,nlags, path, folder, anlR(1,2), degree, delay);

        autocorrelazioni = signalAnalysis(anlR,col,nlags,path,folder);
        s.acr = autocorrelazioni{1,1};
        s.pcr = autocorrelazioni{1,2};
        s.lbq = autocorrelazioni{1,3};
        s.fft = autocorrelazioni{1,4};
        s.psd = autocorrelazioni{1,5};
        %---------------------
        
    elseif opt(j) == "IEI"
        %control the number of switch
        if numberofSwitches == 0
            disp('No switch found, you cannot use IEI! Bye bye');
            return;
        end
        %run burstSelector
        eventi = burstSelector(anlR, timeLength, true, 'thresholdByUser');
        %run IEI
        IEIs = IEI(eventi, 'lastfirst'); %IEIs = IEI(anlR, 'timeDist',timeLength);       
        %-------------------
        IEIGraph = figure;
        histogram(IEIs{1,1}, 20,'Normalization','probability');
        s.IEI = IEIs;
        s.bursts = eventi;
        
        figureNameIEI = ['IEIlf_V',num2str(anlR(1,2)),'_sig',num2str(nos),'_timeThreshold_',erase(num2str(timeLength),'.'),'_method-',method,'.fig'];
        figureNameResistance = ['_V',num2str(anlR(1,2)),'_sig',num2str(nos),'_timeThreshold_',erase(num2str(timeLength),'.'),'_method-',method,'.fig'];
        
        %-----------plot the resistance---------
        resistance = figure;
        plot(anlR(:,1),anlR(:,4));
        hold on;
        for d = 1:size(anlR,1)
            if anlR(d,end) == 1
                plot(anlR(d:d+1,1),anlR(d:d+1,4), 'ro');
            end
        end        
        %coloro i burst
        %hold on
        gridxy(IEIs{1,2}, 'Color','g');

        for j = 1:size(eventi,2)
            gridxy(eventi{1,j}(:,1), 'Color',[1 1 0], 'Linestyle',':');
        end
        annotation('textbox', [.6 .1 .1 .1], 'string',['threshold interval: ', num2str(timeLength), ' s']);
        hold off;
        %---------------------------------------
        savefig(IEIGraph,[path,'\',figureNameIEI]);
        savefig(resistance,[path,'\',figureNameResistance]);

        if ft == 1
            
            [N, edg] = histcounts(IEIs{1,1}, 'BinMethod','fd');
            %----centers copmutation----
            centri = zeros(size(edg,2)-1,1);
            for i = 1:size(edg,2)-1
                centri(i,1) = edg(1,i) + (edg(1,i+1)-edg(1,i))/2;
            end
            %---------------------------                           
            scriptForFit([path,'\',figureNameIEI],centri,IEIs{1,1},'hexp');
        end
        
    elseif opt(j) == "bNb" %number per bin in bursts
        %----time window----
        answer = inputdlg({'Enter the max temporal distance between two switches in the same burst (seconds).'});
        timeLength_ = str2num(answer{1});
        
        build_path = [path,'_V',num2str(anlR(1,2)),'_sig',num2str(nos)...
            ,'_tm',erase(num2str(bl),'.'),'_timeThreshold_',erase(num2str(timeLength_),'.'),'_method-',method];
        %run burstSelector
        eventi = burstSelector(anlR, timeLength_, true, 'thresholdByUser');
        %run numberPerBinInsideBursts
        nbn = numberPerBinInsideBursts(eventi, bl);
        %-------------------
        
        switch ft
            case 1
                show = figure;
                histogram(nbn(:,3));
                answer = inputdlg({'Enter the type of fit for number per bin in burst (hpss-poisson or hlgn-lognormal)'});
                close(show);

                %----carico centri----
                if answer{1} == "hlgn"
                    fitType = 'LGN';
                    M = max(nbn(:,3));
                    edg = 1:M;
                    nbn = nbn(nbn(:,3)~=0,:); 
                elseif answer{1} == "hpss"
                    fitType = 'PSS';
                    M = max(nbn(:,3));
                    edg = 0:M;
                elseif answer{1} == "hexp"
                    fitType = 'EXP';
                    M = max(nbn(:,3));
                    edg = 0:M;
                end
                %---------------------                          
                scriptForFit([build_path,'FITbinInBrst_',fitType,'.fig'],edg', nbn(:,3),answer{1});
            case 0
                M = max(nbn(:,3));
                edg = 0:M;
                figure;
                [N,X]=hist(nbn(:,3),edg);           
                bar(X,N/sum(N)); %prima plot
                title ('SwitchPerBin'); 
                savefig([build_path,'.fig']);    
        end
        s.bNb = nbn;

    elseif opt(j)== "cdt"
        build_path = [path,'\CDT_4sorting_V',num2str(anlR(1,2)),...
            '_sig',num2str(nos),'_deltaT',erase(num2str(deltaT),'.'),'_method-',method,'.fig'];
        %----switching recognition----
        justSwitches = anlR(anlR(:,end)==1, :);
        v = countDeltaT(justSwitches, deltaT);
        [N, edg] = histcounts(v, 'BinMethod','integers','Normalization','probability');
        edg = edg + 0.5;
        edg = edg(1,1:end-1);
        figure
        loglog(edg,N, '-o');
        hold on;
        s.cnt = v;        
        %----shuffled switches----
        random01 = anlR(randperm(size(anlR,1)),end); 
        random_anlR = anlR;
        random_anlR(:,end) = [];
        random_anlR = [random_anlR, random01];
        random_anlR = random_anlR(random_anlR(:,end)==1, :);
        justswitches_rnd = countDeltaT(random_anlR, deltaT);
        [Nrand_, edg_] = histcounts(justswitches_rnd, 'BinMethod','integers','Normalization','probability');
        %centers computation 
        edg_ = edg_ + 0.5;
        edg_ = edg_(1,1:end-1);
        loglog(edg_,Nrand_, '-o');
        legend_ = cell(1,7);
        legend_{1,1} = 'shuffling numero 1';
        hold off;
        savefig(build_path)
        %-------------------------
                
        %{
        max_edg = 0;
        min_edg = Inf; %rivedi
        histSorted = cell(10,2);
        for h = 1:10
            random01 = anlR(randperm(size(anlR,1)),end);            
            for k = 1:3
                random01 = random01(randperm(size(random01,1)),1);
            end
            random_anlR = anlR;
            random_anlR(:,end) = [];
            random_anlR = [random_anlR, random01];
            random_anlR = random_anlR(random_anlR(:,end)==1, :);
            justswitches_rnd = countDeltaT(random_anlR, deltaT);
            [Nrand_, edg_] = histcounts(justswitches_rnd, 'BinMethod','integers');
            edg_ = edg_ + 0.5;
            edg_ = edg_(1,1:end-1);
            histSorted(h,:) = {Nrand_, edg_};
            if max_edg < max(edg_)
               max_edg = max(edg_);
            end
            if min_edg > min(edg_)
               min_edg = min(edg_);
            end
        end
        
        edg_tot = min_edg:1:max_edg;

        
        %calcolo 10 medie 17/05/2019
        means_rnd = zeros(1,size(edg_tot,2));
        for i = 1:size(edg_tot,2)
            means_rnd(1,i) = mean([histSorted{1,1}(1,histSorted{1,2}(1,:) == edg_tot(1,i)),histSorted{2,1}(1,histSorted{2,2}(1,:) == edg_tot(1,i)),... 
            histSorted{3,1}(1,histSorted{3,2}(1,:) == edg_tot(1,i)),histSorted{4,1}(1,histSorted{4,2}(1,:) == edg_tot(1,i)),...
            histSorted{5,1}(1,histSorted{5,2}(1,:) == edg_tot(1,i)),histSorted{6,1}(1,histSorted{6,2}(1,:) == edg_tot(1,i)),...
            histSorted{7,1}(1,histSorted{7,2}(1,:) == edg_tot(1,i)),histSorted{8,1}(1,histSorted{8,2}(1,:) == edg_tot(1,i)),...
            histSorted{9,1}(1,histSorted{9,2}(1,:) == edg_tot(1,i)),histSorted{10,1}(1,histSorted{10,2}(1,:) == edg_tot(1,i))]);
        end        

        
        figure
        loglog(edg_tot,means_rnd, '-o');
        
        figure %%%%%%%%tolto ma funzia
        random_anlR = anlR;
        random_anlR(:,end) = [];
        random_anlR = [random_anlR, random01];
        random_anlR = random_anlR(random_anlR(:,end)==1, :);
        justswitches_rnd = countDeltaT(random_anlR, deltaT);
        [Nrand_, edg_] = histcounts(justswitches_rnd, 'BinMethod','integers');
        edg_ = edg_ + 0.5;
        edg_ = edg_(1,1:end-1);
        loglog(edg_,Nrand_, '-o');
        
        
        title([num2str(anlR(1,2)),' V', num2str(nos),' sigma', ' \Deltat = ', num2str(deltaT), ' s']);
        legend('Swithces in sequenza','Switches shuffled');
        savefig(build_path);
        %}
        
        %----polt bar graph---- attention: not saved!!!
        figure;
        subplot(2,1,1);
        title('Not shuffled');
        plot([anlR(1,1),anlR(end,1)],1, '-');
        hold on;
        notShuffled = anlR(anlR(:,end)==1,:);
        gridxy(notShuffled, 'Color','k');
        plot(notShuffled(:,1),1, 'r*');
        hold off;
        
        subplot(2,1,2);
        title('Shuffled');
        plot([anlR(1,1),anlR(end,1)],1, '-');
        hold on;
        gridxy(random_anlR(:,1), 'Color','k');
        plot(random_anlR(:,1),1, 'r*');
        hold off;
        %----------------------
    end
end
    %%change '\' in '/' on mac
    %build_path = [path,'\V',num2str(anlR(1,2)),'_sig',num2str(nos),'_tm',erase(num2str(bl),'.'),'_dt',num2str(deltaT),'.mat'];
    %save(build_path, 's');
end