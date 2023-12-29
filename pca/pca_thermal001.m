function coeff = pca_thermal001(filename)

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
nframes = size(data,3);
[rows,col] = size(data,1,2);
data_ = zeros(nframes,rows*col);

%data_: nxp matrix. n sono le osservazioni (frames), p i pixel.
for i = 1:nframes
    data_(i,:) = reshape(data(:,:,i),[1,rows*col]); 
end

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

subplot(2,3,1);
hold on;
%first principal component
pc1 = reshape(coeff(:,1),[rows,col]);
title('pc1');
imagesc(pc1);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(2,3,2);
hold on;
title('pc2');
%second principal component
pc2 = reshape(coeff(:,2),[rows,col]);
imagesc(pc2);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(2,3,3);
hold on;
%third principal component
pc3 = reshape(coeff(:,3),[rows,col]);
title('pc3');
imagesc(pc3);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(2,3,4);
hold on;
%fourth principal component
pc4 = reshape(coeff(:,4),[rows,col]);
title('pc4');
imagesc(pc4);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(2,3,5);
hold on;
%fifth principal component
pc5 = reshape(coeff(:,5),[rows,col]);
title('pc5');
imagesc(pc5);
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(2,3,6);
hold on;
%6th principal component
pc6 = reshape(coeff(:,6),[rows,col]);
title('pc6');
imagesc(pc6);
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

savefig(PC, append(filename,'_PC_','.fig'));
savefig(weigths, append(filename,'_pesi_','.fig'));
end