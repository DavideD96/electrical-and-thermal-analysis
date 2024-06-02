function random_series_generator(neventA,neventB,interval,freq)
%UNTITLED Summary of this function goes here
%   interval [s]
%   freq [Hz]

nmeas = interval*freq;
measA = linspace(0,interval,nmeas);
measB = linspace(0,interval,nmeas);
measA = [measA',zeros(nmeas,1)];
measB = [measB',zeros(nmeas,1)];

indA = randperm(nmeas,neventA); 
indB = randperm(nmeas,neventB); 

measA(indA,2) = 1;
measB(indB,2) = 1;
end