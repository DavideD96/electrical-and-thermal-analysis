function results_ordered = IntervalsAnalysis1(T, R, selectInt,folder)

%Date: 2019-03-08 Last Modification: 2019-06-26
%Author: M. Camponovo, D. Decastri
%
%	results = IntervalAnaysis(T,R)
%
%The program perform a analysis to copmute the mean and std deviation of a
%number of intervals selected by the user.
%
%   T: x-axis of th data (usually time)
%   R: y-axis of the data (usually resistance)
%   results: a matrix n*2 where n is the number of intervals selected. The 
%           first column contains the means and the second column the
%           standard deviations of the intervals.
%
%   NOTE: the times are normalized by the program.

%-----normalization----

T = T - T(1,1);

if selectInt == true

    %----interval selection----
    figure;
    subplot(2,1,1);
    histogram(R);
    xlabel('R [a.u.]');
    ylabel('counts');
    subplot(2,1,2);
    plot(T,R, '-k');
    legend('Plot dei dati');
    hold on;
    title('Press any key, select some intervals and then press enter');
    xlabel('time [s]');
    ylabel('quantity to be analyzed [unit]');
    
    pause
    
    intervals = ginput; 
    nIntervals = size(intervals(:,1),1)/2;
    
    c = cell(nIntervals,6);
    hold off;

    figure;
    graph = subplot(2,1,1);
    plot(T,R, '-k');
    legend('Plot dei dati');
    hold on;
    xlabel('time [s]');
    ylabel('quantity to be analyzed [unit]');
    histo = subplot(2,1,2);

    for i = 1:nIntervals
        label_ = ['Intervallo numero ',num2str(i),': ',...
            num2str(intervals((i-1)*2+1,1)), ' s - ', num2str(intervals(2*i,1)), ' s'];
        [subv, lower, upper] = extract_p(T, intervals((i-1)*2+1,1), intervals(2*i,1));

        c(i,1:5) = {i, label_, lower, upper, subv};
        c{i,6} = R(lower:upper);

        subplot(2,1,2);
        subplot(histo);
        hold on;
        histogram(R(lower:upper));
        hold off;
        subplot(2,1,1);
        subplot(graph);
        hold on;
        plot(T(lower:upper), R(lower:upper))
        hold off;
    end    

    check = exist(folder,"dir");

    if check ~= 7
        mkdir(folder)
    end

    cd(folder)
    save 'R_noise_interval.mat' c
    cd ..

    subplot(histo);
    legend(c{:,2});
    xlabel('quantity to be analyzed [unit]');
    ylabel('counts');
    
    subplot(graph);
    cellLegend = [{'Plot dei dati'}, {c{:,2}}];
    legend(cellLegend);
    
    %---merge or not merge---
    answer = 0; %inputdlg({'Inserire i numeri corrispondenti agli intervalli da analizzare separatamente. Inserire il valore 0 per eseguire analisi su tutti gli intervalli insieme.'}); 
    n_choosen = answer; %str2num(answer{1});
    %disp(n_choosen);

else

    nIntervals = 1;
    cd(folder)
    name = 'R_noise_interval.mat';
    c_ = load(name);
    c = c_.c;
    cd ..

    %---merge or not merge---
    answer = 0; %inputdlg({'Inserire i numeri corrispondenti agli intervalli da analizzare separatamente. Inserire il valore 0 per eseguire analisi su tutti gli intervalli insieme.'}); 
    n_choosen = answer; %str2num(answer{1});
    %disp(n_choosen);


end
    
    %---interval analysis---
    if n_choosen == 0
        data = [];
        for k = 1:nIntervals
            data = [data, c{k,6}'];
        end
       
       results_ordered = [mean(data(1,:)),std(data(1,:))];
       
       %---display mean std---
       disp('Media e deviazione standard: ');
       disp(mean(data(1,:)));
       disp(std(data(1,:)));
       
    else
        cNew = cell(size(n_choosen, 2),6);
          
        for j = 1:size(n_choosen, 2)
             for k = 1:nIntervals
                 if n_choosen(j) == c{k,1}
                     %disp(n_choosen(j));
                     cNew(j,:) = c(k,:);
                    
                 end
             end    
        end
       
       results = zeros(size(n_choosen,2),2);
       
       for k = 1:size(n_choosen,2)
           disp(cNew{k,2});
           mean_ = mean(cNew{k,6});
           std_ = std(cNew{k,6});
           results(k,1:2) = [mean_,std_];
           st = ['Mean = ', num2str(mean_), '   std = ', num2str(std_)];
           disp(st);
       end
       
       %---sort the matrix---
       results_ordered  = sortrows(results, 1, 'descend');

   end
   
   
end