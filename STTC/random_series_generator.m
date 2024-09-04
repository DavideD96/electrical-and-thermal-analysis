function [group1, group2] = random_series_generator(neventA,neventB,interval,freq,save_)
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

if save_ == 1
save('group_randA.mat','group1')
group1 = group2;
save('group_randB.mat','group1')
end

% sttc = STTCmultiple_windows('group_randA.mat','group_randB.mat',[0.02,20],50,'plot_figure',0,'save_figure',0);
% 
% 
% figure;
% plot(sttc(:,1),sttc(:,2),'r')
% title(append('rand n eventi = ', num2str(neventA),' ',num2str(neventB)));
% xlabel('\Deltat [s]');
% ylabel('STTC [adim.]');
% grid on
% 
% 
% if save_ == 1
%     savefig(append('rand n eventi = ',num2str(neventA),' ',num2str(neventB)));
% end




end