function [group1, group2] = random_series_generator(neventA,neventB,interval,freq,save)
%UNTITLED Summary of this function goes here
%   interval [s]
%   freq [Hz]

nmeas = interval*freq;
group1 = linspace(0,interval,nmeas);
group2 = linspace(0,interval,nmeas);
group1 = [group1',zeros(nmeas,1)];
group2 = [group2',zeros(nmeas,1)];

indA = randperm(nmeas,neventA); 
indB = randperm(nmeas,neventB); 

group1(indA,2) = 1;
group2(indB,2) = 1;


if save == 1
    save('group_randA.mat','group1')
    group1 = group2;
    save('group_randB.mat','group1')
end

end