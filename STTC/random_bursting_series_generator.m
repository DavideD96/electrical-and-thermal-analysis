function [group1,group2]=random_bursting_series_generator(neventA,neventB,interval,freq,ninburst,barcodes,save)
%UNTITLED Summary of this function goes here
%   interval [s]
%   freq [Hz]

nmeas = interval*freq;
group1 = linspace(0,interval,nmeas);
group2 = linspace(0,interval,nmeas);
group1 = [group1',zeros(nmeas,1)];
group2 = [group2',zeros(nmeas,1)];

indA = randperm(nmeas,round(neventA/ninburst)); 
indB = randperm(nmeas,round(neventB/ninburst)); 

while nmeas < max(indA)+3*ninburst
    indA = randperm(nmeas,round(neventA/ninburst));
end
while nmeas < max(indB)+3*ninburst
    indB = randperm(nmeas,round(neventB/ninburst));
end

group1(indA,2) = 1;
group2(indB,2) = 1;

for j = 1:ninburst-1
    group1(indA+3*j,2) = group1(indA,2); %li metto distanziati di 2
end

for j = 1:ninburst-1
    group2(indB+3*j,2) = group2(indB,2); %li metto distanziati di 2
end

if save == 1
save('group_randA.mat','group1')
end

if barcodes == 1
figure('Position',[100 100 1000 150]);
%title(append(name,' events'));
set(gca,'fontsize', 14) 
%plot([anlR(1,1),anlR(end,1)],1, '-');
xlim([group1(1,1),group1(end,1)]);
hold on;
gridxy(group1(group1(:,2)~=0,1),'Color','k');
%savefig(append(name,'_barCode'));
%saveas(b, append(name,'_barCode.png'),'png');
figure('Position',[100 100 1000 150]);
%title(append(name,' events'));
set(gca,'fontsize', 14) 
%plot([anlR(1,1),anlR(end,1)],1, '-');
xlim([group2(1,1),group2(end,1)]);
hold on;
gridxy(group2(group2(:,2)~=0,1),'Color','k');
end

if save == 1
group1 = group2;
save('group_randB.mat','group1')
end

end