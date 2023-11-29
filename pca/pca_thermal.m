function coeff = pca_thermal(filename,Th_analysis, frames, onlyEvents)

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

event = 0;

testsize = load(append(filename,num2str(frames(1))));
[rows,col] = size(testsize.a);
data = zeros(frames(2)-frames(1)+1,rows*col);

for i = frames(1):frames(2)
    if Th_analysis(i,end) ~= 0 && Th_analysis(i,end) ~= event
        event = Th_analysis(i,end);
        dataMat = load(append(filename,num2str(i)));
        data(i,:) = dataMat.a(:); %all data in a column vector
    end
end

%remove extra columns (all zeros)
data( :, all( ~data, 1 ) ) = [];

%coeff sono i coefficienti delle componenti principali. Ogni colonna
%rappresenta una componente principale nella base delle osservabili fisiche
%originarie

coeff = pca(data);
pcaSignificance = sqrt(sum(coeff.^2, 1));

plot(linespace(1,10,10), sqrt(pcaSignificance(1:10)));

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

end