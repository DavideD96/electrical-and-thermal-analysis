function IEIs = IEI(bursts,type)

%Date: 2019-05-19 Last Modification: 2019-05-19
%Author: D. Decastri
%
%   IEIs = IEI(bursts,type)
%
%this program returns a 1x2 cell array containing the array of the
%distances between the bursts in position 1,1, and an array containing the
%centres of the bursts in position 1,2.
%
%   bursts: a 1Xn cell array containing in each colum a matrix that
%           corresponds to a burst: in the first colum of the matrices must
%           be stored the sampling times.
%   type: if type is "lastfirst", the IEI are considered the time intervals
%         between the last switch of the previous burst and the first
%         switch of the next burst.
%         If type is "centres" IEI is the interval betwee the centres of
%         consecutive bursts.
%   IEIs: a 1x2 cell array containing IEI in position 1,1, the centres of
%         the bursts in position 1,2.

InterEventInterval = zeros(size(bursts,2)-1,1);
centri = zeros(size(bursts,2),1);

for j = 1:size(bursts,2)
    centri(j,1) = (bursts{1,j}(end,1)- bursts{1,j}(1,1))/2 + bursts{1,j}(1,1);
end

if type == "lastfirst"        
    for i = 1:size(bursts,2)-1
        InterEventInterval(i,1) = bursts{1,i+1}(1,1) - bursts{1,i}(end,1);
    end
elseif type == "centres"
    InterEventInterval = diff(centri);
end


IEIs = {InterEventInterval, centri};
end