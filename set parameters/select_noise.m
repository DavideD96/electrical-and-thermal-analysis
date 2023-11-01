function results_ordered = select_noise(filename)

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

R_ = load(nomefile).R;

T = R_(:,1);
R = R_(:,end);

T = T - T(1,1);

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
    plot(T(lower:upper), R(lower:upper));
    hold off;
end    

cd('parameters')
save 'R_noise_interval.mat' c
cd ..

subplot(histo);
legend(c{:,2});
xlabel('quantity to be analyzed [unit]');
ylabel('counts');

subplot(graph);
cellLegend = [{'Plot dei dati'}, {c{:,2}}];
legend(cellLegend);
   
end