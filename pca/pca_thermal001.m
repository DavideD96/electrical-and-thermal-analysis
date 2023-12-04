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
data = data.mtotalEvT;
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

plot(linspace(1,10,10), pcaSignificance(1:10));
xlabel('pca component');
ylabel('variance %');
set(gca, 'XTick', 1:10)

%plot eigenvalues of covariance matrix
figure
plot(linspace(1,10,10), latent(1:10));
xlabel('pca component');
ylabel('latent');
set(gca, 'XTick', 1:10)

%first principal component
pc1 = reshape(coeff(:,1),[rows,col]);
figure
title('pc1');
imagesc(pc1);
colorbar

%second principal component
pc2 = reshape(coeff(:,2),[rows,col]);
figure
title('pc2');
imagesc(pc2);
colorbar

%third principal component
pc3 = reshape(coeff(:,3),[rows,col]);
figure
title('pc3');
imagesc(pc3);
colorbar

%fourth principal component
pc4 = reshape(coeff(:,4),[rows,col]);
figure
title('pc4');
imagesc(pc4);
colorbar

%fifth principal component
pc5 = reshape(coeff(:,5),[rows,col]);
figure
title('pc5');
imagesc(pc5);
colorbar

%7th principal component
pc7 = reshape(coeff(:,7),[rows,col]);
figure
title('pc7');
imagesc(pc7);
colorbar


%reconstruct frame 1
fr1 = reshape(scores(1,:)*coeff'+ repmat(mu1,1,1),[rows,col]); %i dati sono centrati, il numero di gradi di libertà è n-1
figure
title('fr1');
imagesc(fr1);
colorbar

end