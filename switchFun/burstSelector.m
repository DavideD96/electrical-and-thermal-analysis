function bursts = burstSelector(datiAnalizzati, timeInBurst, excludeSpikesAlone, method)

%Date: 2019-05-19 Last Modification: 2019-05-19
%Author: D. Decastri
%
%   bursts = burstSelector(datiAnalizzati, timeInBurst, excludeSpikesAlone, method)
%
%this program return a cell row array containing in each cell a portion of 
%'datiAnalizzati', that correspond to a burst of activity.
%
%   datiAnalizzati: matrix containing in the last column '0' or '1'
%                   correspondingly to the switches found.
%   timeInBurst: time that specify the maximum distance between two
%                switches in the same burst. This parameter is used just
%                with method "thresholdByUser".
%   excludeSpikesAlone: if 'true', the bursts containing just two switches
%                       are excluded from the results.
%   method: with the method "thresholdByUser" the bursts are identified
%               considering that the maximum distance between tho switch in
%               the same burst is 'timeInBurst'. The method "neuronsDef2" 
%               consist in considering a burst as a sequence of switches
%               that are separate by time intervals smaller than the mean 
%               'Inter Spike Interval'. This method is inpired by the
%               studies on biological neural network by Mazzoni et al.               
%               

if method == "neuronsDef2"
    isi = ISI(datiAnalizzati, 'full');
    timeInBurst = mean(isi);
end

datiAnalizzati = [datiAnalizzati, zeros(size(datiAnalizzati, 1),1)];

%add column for indexing
for i = 1:size(datiAnalizzati, 1)
    datiAnalizzati(i,end) = i;
end

dati = datiAnalizzati(datiAnalizzati(:,end-1)==1, :);
numberOfBurst = 1;

for j = 1:(size(dati,1)-1)
    if dati(j+1,1)- dati(j,1) > timeInBurst
        numberOfBurst = numberOfBurst + 1;
    end
end

bursts = cell(1,numberOfBurst);
numberBurst = 1;
startBurst = 1;

for j = 1:(size(dati,1)-2)
    if dati(j+1,1) - dati(j,1) > timeInBurst
        endBurst = j;
        bursts{1,numberBurst} = datiAnalizzati(dati(startBurst,end):dati(endBurst,end),:);
        startBurst = j+1;
        numberBurst = numberBurst +1;
    end
end

if dati(size(dati,1),1)- dati(size(dati,1)-1,1) <= timeInBurst
    endBurst = size(dati,1);
    bursts{1,numberBurst} = datiAnalizzati(dati(startBurst,end):dati(endBurst,end),:);
else
    endBurst = size(dati,1)-1;
    bursts{1,numberBurst} = datiAnalizzati(dati(startBurst,end):dati(endBurst,end),:);
    numberBurst = numberBurst + 1;
    bursts{1,numberBurst} = datiAnalizzati(dati(end,end),:);
end

if excludeSpikesAlone == true
    sizes = zeros(1,numberBurst);
    
    for k = 1:numberBurst
        sizes(1,k) = size(bursts{1,k},1);
    end
    
    spikesAlone = sizes(1,:) <= 3;
    bursts = bursts(1,~spikesAlone);
end
end