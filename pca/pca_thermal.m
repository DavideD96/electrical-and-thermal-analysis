function coeff = pca_thermal(filename, frames, onlyEvents)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-29 Last modification: -
%
%Author: Davide Decastri
%perform pca analysis using detected events (but excluding multiple frames
%related to the same event), or all the frames together.
%
% filename: name of the Thermal file
% Th_analysis: results of Analisi_Nframes011
% frames: start-end
% onlyEvents: true -> perfomr pca analysis only on frames belonging to
%               DIFFERENT events
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

storeall = 1;
event = 0;

testsize = load(append(filename,num2str(frames(1))));
[rows,col] = size(testsize.a);
data = zeros(frames(2)-frames(1)+1,rows*col);

if storeall == 1

    % for i = frames(1):frames(2)
    %     if Th_analysis(i,end) ~= 0 && Th_analysis(i,end) ~= event
    %         event = Th_analysis(i,end);
    %         dataMat = load(append(filename,num2str(i)));
    %         data(i,:) = dataMat.a(:); %all data in a column vector
    %     end
    % end
    
    for i = frames(1):frames(2)
        dataMat = load(append(filename,num2str(i)));
        data(i,:) = dataMat.a(:); %all data in a column vector    
    end

    %data: nxp matrix. n sono le osservazioni (frames), p i pixel.
    %remove extra columns (all zeros)
    data( :, all( ~data, 1 ) ) = [];
    
    %coeff sono i coefficienti delle componenti principali. Ogni colonna
    %rappresenta una componente principale nella base delle osservabili fisiche
    %originarie il numero massimo di coefficienti è pari al numero di pixel
    
    %di default pca centra i dati, per cui i gradi di libertà massimi sono
    %n-1, non n. Puoi anche impostare 'Centered',false
    [coeff,scores,latent,tsquared,explained,mu1] = pca(data);
    
elseif storeall == 0


end

pcaSignificance = explained;

plot(linspace(1,5,5), pcaSignificance(1:5));
xlabel('pca component');
ylabel('variance %');
set(gca, 'XTick', 1:5)

%plot eigenvalues of covariance matrix
figure
plot(linspace(1,5,5), latent(1:5));
xlabel('pca component');
ylabel('latent');
set(gca, 'XTick', 1:5)

%first principal component
pc1 = reshape(coeff(:,1),3,3);
figure
title('pc1');
imagesc(pc1);
colorbar

%second principal component
pc2 = reshape(coeff(:,2),3,3);
figure
title('pc2');
imagesc(pc2);
colorbar

%reconstruct frame 1
fr1 = reshape(scores(1,:)*coeff'+ repmat(mu1,1,1),3,3); %i dati sono centrati, il numero di gradi di libertà è n-1
figure
title('fr1');
imagesc(fr1);
colorbar

end