function mean_ColdAndHot(varargin)

% given a video for conduction mapping, this function computes the mean of
% the frames when current flows and subtracts it to mean computed when the
% film does not conduct. Given the frames when application starts and end,
% 3 frames before and after each transient are excluded.
%

check = exist("termoFiles_mat\","dir");
if check ~= 0
    cd termoFiles_mat\
end

startEnd = load('PULSE_startEnd.mat');
startEnd = startEnd.t_startEnd;
nframesHot = startEnd(2)-startEnd(1);
ntrials = 200; %per cercare autonomamente il punto in cui si scalda

num = length(varargin);

mtot = load('mtotalT.mat');
mtot = mtot.mtotalT;

if num > 0
    nframesHot = varargin{1};

else

    index = 1;
    deltaTmax = 0.1;

    for ii = 1:ntrials
        cold = mean(mtot(:,:,ii:ii+50),3);
        hot = mean(mtot(:,:,ii++53:ii+103),3);
        deltaT = max(hot-cold,[],'all');

        if deltaT>deltaTmax
            deltaTmax = deltaT;
            index = ii+52;
        end

    end
end


start = startEnd(1);

transient = 6; %exclude frames due to transient

coldData = mtot(:,:,1:(start - transient/2)); %-1
coldData = cat(3,coldData,mtot(:,:,(start + transient/2 + nframesHot + 1):(nframesHot + nframesHot + 1)));
hotData = mtot(:,:,(start + transient/2):(start - transient/2 + nframesHot - 1));

%size(coldData)
%size(hotData)

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

save('coldMean.mat','coldMean');
save('hotMean.mat','hotMean');
save('start_apply.mat',"index")

imagesc(hotMean-coldMean);

if check ~= 0
    cd ..
end

end