function AS_temperature_evolution(x,y)

%AS_temperature_evolution
%
% x = row
% y = column

% x = 85;
% y = 17;

%cd termoFiles_mat

m = load("mtotalT.mat");
m = m.mtotalT;

%cd ..

AS = m(x,y,:);

t = linspace(0,size(m,3)*0.02,size(m,3));

figure
plot(t,AS(:))
figure
histogram(AS(AS ~= 0))

end