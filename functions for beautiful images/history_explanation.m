function history_explanation(fr1,fr2,fr3)

load('ThermoColorMap2.mat');

limite_h = [42,82];
limite_w = [7,7];

mtot = load("mtotalT.mat");
mtot = mtot.mtotalT;
mtot = mtot(limite_h(1):limite_h(2),:,:);
mtot = mtot(:,limite_w(1):end-limite_w(2),:);

max_ = max([mtot(:,:,fr1),mtot(:,:,fr2),mtot(:,:,fr3)],[],'all');
min_ = min([mtot(:,:,fr1),mtot(:,:,fr2),mtot(:,:,fr3)],[],'all');

max_ = max_+0.5;

history = reshape(max(mtot,[],2),[size(mtot,1),size(mtot,3),1]);

[~,ind] = max(mtot(:,:,fr1),[],2); 
figure
subplot(1,3,1)
title(num2str(fr1))
colormap(cm)
imagesc(mtot(:,:,fr1))
clim([min_ max_])
hold on

for kk = 1:size(mtot,1)
    plot([ind(kk)-0.5,ind(kk)-0.5,ind(kk)+0.5,ind(kk)+0.5,ind(kk)-0.5],[kk+0.5,kk-0.5,kk-0.5,kk+0.5,kk+0.5],'w','linewidth',1)
end

axis equal
axis off
hold off


[~,ind] = max(mtot(:,:,fr2),[],2);
%figure
subplot(1,3,2)
title(num2str(fr2))
colormap(cm)
imagesc(mtot(:,:,fr2))
clim([min_ max_])
hold on

for kk = 1:size(mtot,1)
    plot([ind(kk)-0.5,ind(kk)-0.5,ind(kk)+0.5,ind(kk)+0.5,ind(kk)-0.5],[kk+0.5,kk-0.5,kk-0.5,kk+0.5,kk+0.5],'w','linewidth',1)
end

axis equal
axis off
hold off


[~,ind] = max(mtot(:,:,fr3),[],2);
%figure
subplot(1,3,3)
title(num2str(fr3))
imagesc(mtot(:,:,fr3))
colormap(cm)
clim([min_ max_])
hold on

for kk = 1:size(mtot,1)
    plot([ind(kk)-0.5,ind(kk)-0.5,ind(kk)+0.5,ind(kk)+0.5,ind(kk)-0.5],[kk+0.5,kk-0.5,kk-0.5,kk+0.5,kk+0.5],'w','linewidth',1)
end

max_h = max([history(:,fr1),history(:,fr2),history(:,fr3)],[],'all');
min_h = min([history(:,fr1),history(:,fr2),history(:,fr3)],[],'all');

max_h = max_h+0.5;

axis equal
axis off
hold off

figure
subplot(1,3,1)
imagesc(history(:,fr1))
colormap(cm)
clim([min_h max_h])
title(num2str(fr1))
axis off
axis equal

%figure
subplot(1,3,2)
imagesc(history(:,fr2))
colormap(cm)
clim([min_h max_h])
title(num2str(fr2))
axis off
axis equal

%figure
subplot(1,3,3)
imagesc(history(:,fr3))
colormap(cm)
clim([min_h max_h])
colorbar
title(num2str(fr3))
axis off
axis equal

figure
imagesc(history(:,fr1-5:fr3+5)); %[history(:,fr1),history(:,fr2),history(:,fr3)])
colormap(cm)
colorbar('southoutside','FontSize',14)
axis equal
axis off
end