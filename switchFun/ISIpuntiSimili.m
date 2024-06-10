function int = ISIpuntiSimili(group,method,varargin)

%Date: 2019-02-18 Last Modification: --
%Author: M. Camponovo, D. Decastri, M. Mirigliano
%           int = ISI(analyzed,method)
%The program anlyzed the last column of matrix 'analyzed' and collects the
%time distance between two switch.
%           
%   analyzed = (times,switchfound)
%   method: if method = full all consecutive switch interval are computed 
%           if method = half only couples of switches interval are computed
%
%   int = matrix that contain the time distance beetwen two switch

group_ = load(group);
group_ = group_.group1;

num = size(varargin,2);
nBin = 0;
int = [];

for k = 1:2:num
    if prod(varargin{k}=='nBin')
        nBin = varargin{k+1};
    end
end

if prod(method == 'full')

    s = size(group_(:,1));
    j = 1;

    firstInd = find(group_(:,2),1, 'first');
    t1 = group_(firstInd,1);

    for i=firstInd+1:1:s
        if (group_(i,2) ~= 0)
            t2 = group_(i,1);
            int(j,1) = t2-t1;
            j=j+1;
            t1 = t2;
        end
    end
    
elseif prod(method == 'half')
    
    s = size(group_(:,1));
    k = 0;
    j = 1;
    for i=1:s
        if (group_(i,2) ~= 0) & (k==0)
            k =1;
            t1 = group_(i,1);
        elseif (group_(i,2) ~= 0) & (k==1)
            k =0;
            t2 = group_(i,1);
            int(j,1) = t2-t1;
            j=j+1;
        end
    end
else
    disp('Unknown method.');
    return;
end

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
name = erase(group,'.mat');
title(append(name,' ISI'));
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
 
     
