function [originalHist,randomHist] = BarabasiPuntiSimili(analyzed,timeWindow)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

justSwitches = analyzed(analyzed(:,2)~=0, :);
%size(justSwitches)
v = countDeltaT(justSwitches, timeWindow);
[N, edg] = histcounts(v, 'BinMethod','integers','Normalization','probability');
edg = edg + 0.5;
edg = edg(1,1:end-1);
figure
loglog(edg,N, '-o');
hold on;

originalHist.histCount = N;
originalHist.histCentres = edg;

random01 = analyzed(randperm(size(analyzed,1)),2); 
random01(random01~=0) = 1; 
random_anlR = analyzed;

random_anlR = [random_anlR, random01];
random_anlR = random_anlR(random_anlR(:,end)==1, :);

justswitches_rnd = countDeltaT(random_anlR, timeWindow);
[Nrand_, edg_] = histcounts(justswitches_rnd, 'BinMethod','integers','Normalization','probability');

%centers computation 
edg_ = edg_ + 0.5;
edg_ = edg_(1,1:end-1);
loglog(edg_,Nrand_, '-o');
legend_ = cell(1,7);
legend_{1,1} = 'shuffling numero 1';
hold off;

randomHist.histCount = Nrand_;
randomHist.histCentres =  edg_;

figure;
subplot(2,1,1);
title('Not shuffled');
anlR01 = analyzed(:,2);
anlR01(anlR01~=0) = 1;

xlim([analyzed(1,1),analyzed(end,1)]);
hold on;
notShuffled = analyzed(anlR01(:,end)==1,:);
gridxy(notShuffled(:,1), 'Color','k');
hold off;

subplot(2,1,2);
title('Shuffled');

xlim([analyzed(1,1),analyzed(end,1)]);
hold on;
gridxy(random_anlR(:,1), 'Color','k');
hold off;
%----------------------
end