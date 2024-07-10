function ISIfit(int,varargin)

%Date: 2019-02-18 Last Modification: --
%Author: M. Camponovo, D. Decastri, M. Mirigliano
%           int = ISI(analyzed,method)
%The program anlyzed the last column of matrix 'analyzed' and collects the
%time distance between two switch.
%           
%   analyzed = (times,switchfound)
%   int = matrix that contain the time distance beetwen two switch

a = load('')

if nBin ~= 0
    [num, edg] = histcounts(int,nBin);
else
    [num, edg] = histcounts(int);
end

for k = 1:size(edg,2)-1
    cent(k,1) = (edg(k+1)+edg(k))/2;
end

a = figure;
loglog(cent,num,'-o')
grid on
name = 'ISI';
savefig(append(name,'_ISI'));
saveas(a, append(name,'_ISI.png'),'png');

b = figure('Position',[100 100 1000 150]);
title(append(name,' events'));
set(gca,'fontsize', 14) 
%plot([anlR(1,1),anlR(end,1)],1, '-');
xlim([group_(1,1),group_(end,1)]);
hold on;
gridxy(group_(group_(:,2)~=0,1),'Color','k');
savefig(append(name,'_barCode'));
saveas(b, append(name,'_barCode.png'),'png');

end
 
     
