function mean_ColdAndHot(nframesHot)

% given a video for conduction mapping, this function computes the mean of
% the frames when current flows and subtracts it to mean computed when the
% film does not conduct. Given the frames when application starts and end,
% 3 frames before and after each transient are excluded.
%

cd termoFiles_mat\
startEnd = load('PULSE_startEnd.mat');
startEnd = startEnd.t_startEnd;
mtot = load('mtotalT.mat');
mtot = mtot.mtotalT;
start = startEnd(1);

transient = 6; %exclude frames due to transient

coldData = mtot(:,:,1:(start - transient/2)); %-1
coldData = cat(3,coldData,mtot(:,:,(start + transient/2 + nframesHot + 1):(nframesHot + nframesHot + 1)));
hotData = mtot(:,:,(start + transient/2):(start - transient/2 + nframesHot - 1));

size(coldData)
size(hotData)

% se vuoi le cose più precise
% if start - nframesHot/2 > 0
%     coldData = mtot(:,:,(start - nframesHot/2):(start-1));
%     coldData = [coldData,mtot(:,:,(start + nframesHot +1):(start + nframesHot + nframesHot/2))];
%     hotData = mtot(:,:,start:(start+nframesHot));
% else
%     coldData = mtot(:,:,(start + nframesHot):(start-1));
%     coldData = [coldData,mtot(:,:,(start + nframesHot +1):(start + nframesHot + nframesHot/2))];
%     hotData = mtot(:,:,start:(start+nframesHot));
% end

coldMean = mean(coldData,3);
hotMean = mean(hotData,3);

imagesc(hotMean-coldMean);

cd ..

end