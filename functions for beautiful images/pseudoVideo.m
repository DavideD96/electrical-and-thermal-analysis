frames = [1,10,100];
appendedM = [mtotalT(:,:,frames(1)),mtotalT(:,:,frames(2)),mtotalT(:,:,frames(3))];
limits = [min(appendedM,[],'all'),max(appendedM,[],'all')];

tiledlayout(1,3);

for ii = 1:3
    nexttile
    imagesc(mtotalT(:,:,frames(ii)))
    clim(limits)
end
