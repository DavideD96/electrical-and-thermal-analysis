function coeff = pca_thermal003(filename,fileres,start_end)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-29 Last modification: -
%
%Author: Davide Decastri
%perform pca analysis using detected events (but excluding multiple frames
%related to the same event), or all the frames together.
%
% filename: name of the Thermal file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = load(filename,'-mat');
data = cell2mat(struct2cell(data));

res = load(fileres);
res = cell2mat(struct2cell(res));
%res = res(delay:end,:);

if start_end == 0
    nframes = size(data,3);
    starting_frame = 1;
else
    nframes = start_end(2)-start_end(1);
    starting_frame = start_end(1);
end

[rows,col] = size(data,1,2);
data_ = zeros(nframes,rows*col);

%data_: nxp matrix. n sono le osservazioni (frames), p i pixel.
for i = 0:nframes-1
    data_(i+1,:) = reshape(data(:,:,starting_frame+i),[1,rows*col]); 
end
% nframes
% size(data_)

%per ricostruire data:
%data = reshape(data_',[rows,col,nframes]); %da testare

clear data

%coeff sono i coefficienti delle componenti principali. Ogni colonna
%rappresenta una componente principale nella base delle osservabili fisiche
%originarie il numero massimo di coefficienti è pari al numero di pixel

%di default pca centra i dati, per cui i gradi di libertà massimi sono
%n-1, non n. Puoi anche impostare 'Centered',false
[coeff,scores,latent,tsquared,explained,mu1] = pca(data_);
    
pcaSignificance = explained;

weigths = figure;
plot(linspace(1,12,12), pcaSignificance(1:12));
xlabel('pca component');
ylabel('variance %');
grid on;
set(gca, 'XTick', 1:12)

% %plot eigenvalues of covariance matrix
% figure
% plot(linspace(1,10,10), latent(1:10));
% xlabel('pca component');
% ylabel('latent');
% set(gca, 'XTick', 1:10)

PC = figure;

subplot(3,3,1);
hold on;
%first principal component
pc1 = reshape(coeff(:,1),[rows,col]);
title('pc1');
imagesc(pc1);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,2);
hold on;
title('pc2');
%second principal component
pc2 = reshape(coeff(:,2),[rows,col]);
imagesc(pc2);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,3);
hold on;
%third principal component
pc3 = reshape(coeff(:,3),[rows,col]);
title('pc3');
imagesc(pc3);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,4);
hold on;
%fourth principal component
pc4 = reshape(coeff(:,4),[rows,col]);
title('pc4');
imagesc(pc4);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,5);
hold on;
%fifth principal component
pc5 = reshape(coeff(:,5),[rows,col]);
title('pc5');
imagesc(pc5);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,6);
hold on;
%6th principal component
pc6 = reshape(coeff(:,6),[rows,col]);
title('pc6');
imagesc(pc6);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,7);
hold on;
%6th principal component
pc7 = reshape(coeff(:,7),[rows,col]);
title('pc7');
imagesc(pc7);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,8);
hold on;
%6th principal component
pc8 = reshape(coeff(:,8),[rows,col]);
title('pc8');
imagesc(pc8);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,3,9);
hold on;
%6th principal component
pc9 = reshape(coeff(:,9),[rows,col]);
title('pc9');
imagesc(pc9);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

sgtitle('first principal components')

% figure
% %7th principal component
% pc7 = reshape(coeff(:,7),[rows,col]);
% title('pc7');
% imagesc(pc7);
% colorbar

% %reconstruct frame 1
% fr1 = reshape(scores(1,:)*coeff'+ repmat(mu1,1,1),[rows,col]); %i dati sono centrati, il numero di gradi di libertà è n-1
% figure
% title('fr1');
% imagesc(fr1);
% colorbar
% 

PC2 = figure;
imagesc(pc2);
title('principal component 2')
colorbar

PC4 = figure;
imagesc(pc4);
title('principal component 4')
colorbar

%nframes
check = rem(nframes,3);

if check == 1
    nframes = nframes-1;
    scores = scores(1:end-1,:);
elseif check == 2
    nframes = nframes-2;
    scores = scores(1:end-2,:);
end

res = res(1:(nframes)/1.5,:);
period = 1/60;
times = linspace(0,period*nframes*2,nframes*2);
times = times';

scores_ = repelem(scores,2,1);
res_ = repelem(res,3,1);

size(res_)
size(scores_)

data = table(times,res_(:,4), scores_(:,1),scores_(:,2),scores_(:,3),scores_(:,4), scores_(:,5), scores_(:,6));
data = renamevars(data,'times','times [s]');

data.Properties.VariableUnits = {'[s]','[Ohm]','adim','adim','adim','adim','adim','adim'};

degreeSymbol = char(176);
newYlabels = ["time [s]","resistance [Ohm]","PC1","PC2","PC3","PC4","PC5","PC6"];
plt = stackedplot(data,'Title','Stacked Data','DisplayLabels',newYlabels, 'XVariable','times [s]');
grid on;

savefig(PC2, append(filename,'_PC2_','.fig'));
savefig(PC4, append(filename,'_PC4_','.fig'));
savefig(PC, append(filename,'_PC_','.fig'));
savefig(weigths, append(filename,'_pesi_','.fig'));
end