%AS_temperature_evolution
%
% x = row
% y = column

x = 8;
y = 20;

m = load("mtotalT.mat");
m = m.mtotalT;
AS = m(x,y,:);

t = linspace(0,size(m,3)*0.02,size(m,3));

plot(t,AS(:))