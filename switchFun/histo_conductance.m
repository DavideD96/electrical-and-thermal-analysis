load('detection.mat', 's');
data = s.detection;
data = data(data(:,6) ~= 0,:);
histogram(data(:,6),20)
xlabel('Conductance [\Omega^-1]')
ylabel('Counts')
grid on