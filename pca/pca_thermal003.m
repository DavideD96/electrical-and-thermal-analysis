function pc2 = pca_thermal003(filename,fileres,start_end, varargin)

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

clustering = false;
N_significant_PC = 5;
use_electr = false;
smooth = false;

num = size(varargin,2);

for k = 1:2:num
    if prod(varargin{k}=='kmean_clustering')
        clustering = varargin{k+1};
    elseif prod(varargin{k}=='N_significant_PC')
        N_significant_PC = varargin{k+1};
    elseif prod(varargin{k}=='add_electric_dat')
        use_electr = varargin{k+1};
    elseif prod(varargin{k}=='smoothing_before')
        smooth = varargin{k+1};

    end
end

data = load(filename,'-mat');
data = cell2mat(struct2cell(data));

if use_electr == true
    res = load(fileres);
    res = cell2mat(struct2cell(res));
end
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
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%% explained %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pcaSignificance = explained;

weigths = figure;
plot(linspace(1,20,20), pcaSignificance(1:20));
xlabel('pca component');
ylabel('variance %');
grid on;
set(gca, 'XTick', 1:20)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%% cumulative explained %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pcaCSignificance = cumsum(pcaSignificance(1:50));
plot(linspace(1,50,50), pcaCSignificance);
xlabel('n° of pca components');
ylabel('explained variance %');
grid on;
set(gca, 'XTick', 1:50)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %plot eigenvalues of covariance matrix
% figure
% plot(linspace(1,10,10), latent(1:10));
% xlabel('pca component');
% ylabel('latent');
% set(gca, 'XTick', 1:10)

PC = figure;

subplot(3,4,1);
hold on;
%first principal component
pc1 = reshape(coeff(:,1),[rows,col]);
title('pc1');
imagesc(flip(pc1,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,2);
hold on;
title('pc2');
%second principal component
pc2 = reshape(coeff(:,2),[rows,col]);
imagesc(flip(pc2,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,3);
hold on;
%third principal component
pc3 = reshape(coeff(:,3),[rows,col]);
title('pc3');
imagesc(flip(pc3,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,4);
hold on;
%fourth principal component
pc4 = reshape(coeff(:,4),[rows,col]);
title('pc4');
imagesc(flip(pc4,1));
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,5);
hold on;
%fifth principal component
pc5 = reshape(coeff(:,5),[rows,col]);
title('pc5');
imagesc(flip(pc5,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,6);
hold on;
%6th principal component
pc6 = reshape(coeff(:,6),[rows,col]);
title('pc6');
imagesc(flip(pc6,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,7);
hold on;
%7th principal component
pc7 = reshape(coeff(:,7),[rows,col]);
title('pc7');
imagesc(flip(pc7,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,8);
hold on;
%8th principal component
pc8 = reshape(coeff(:,8),[rows,col]);
title('pc8');
imagesc(flip(pc8,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,9);
hold on;
%9th principal component
pc9 = reshape(coeff(:,9),[rows,col]);
title('pc9');
imagesc(flip(pc9,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,10);
hold on;
%10th principal component
pc10 = reshape(coeff(:,10),[rows,col]);
title('pc10');
imagesc(flip(pc10,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,11);
hold on;
%11th principal component
pc11 = reshape(coeff(:,11),[rows,col]);
title('pc11');
imagesc(flip(pc11,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

subplot(3,4,12);
hold on;
%12th principal component
pc12 = reshape(coeff(:,12),[rows,col]);
title('pc12');
imagesc(flip(pc12,1));
xlim([1,col]);
ylim([1,rows]);
colorbar
hold off;

% subplot(5,4,13);
% hold on;
% %13th principal component
% pc13 = reshape(coeff(:,13),[rows,col]);
% title('pc13');
% imagesc(pc13);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,14);
% hold on;
% %14th principal component
% pc14 = reshape(coeff(:,14),[rows,col]);
% title('pc14');
% imagesc(pc14);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,15);
% hold on;
% %15th principal component
% pc15 = reshape(coeff(:,15),[rows,col]);
% title('pc15');
% imagesc(pc15);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,16);
% hold on;
% %16th principal component
% pc16 = reshape(coeff(:,16),[rows,col]);
% title('pc16');
% imagesc(pc16);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,17);
% hold on;
% %17th principal component
% pc17 = reshape(coeff(:,17),[rows,col]);
% title('pc17');
% imagesc(pc17);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,18);
% hold on;
% %18th principal component
% pc18 = reshape(coeff(:,18),[rows,col]);
% title('pc18');
% imagesc(pc18);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,19);
% hold on;
% %19th principal component
% pc19 = reshape(coeff(:,19),[rows,col]);
% title('pc19');
% imagesc(pc19);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;
% 
% subplot(5,4,20);
% hold on;
% %9th principal component
% pc20 = reshape(coeff(:,20),[rows,col]);
% title('pc20');
% imagesc(pc20);
% xlim([1,col]);
% ylim([1,rows]);
% colorbar
% hold off;

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

if use_electr == true
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
    data = table(times,1./res_(:,4), scores_(:,1),scores_(:,2),scores_(:,3),scores_(:,4), scores_(:,5), scores_(:,6), scores_(:,7), scores_(:,8), scores_(:,9), scores_(:,10));
    % data = renamevars(data,'times','times [s]');
    % 
    % data.Properties.VariableUnits = {'[s]','[Ohm^-1]','[K]','[K]','[K]','[K]','[K]','[K]','[K]','[K]','[K]','[K]'};
    % 
    % degreeSymbol = char(176);
    data_ = table2array(data);
    newYlabels = ["time [s]","conductance [Ohm^-1]","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10"];
    fig = figure;
    subplot(10,1,1);
    plot(data_(:,1),data_(:,2))
    ylabel('conductance [\Omega^-1]')
    set(gca,'xtick',[])

    subplot(10,1,2)
    plot(data_(:,1),data_(:,3))
    ylabel('PC1')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,3)
    plot(data_(:,1),data_(:,4))
    ylabel('PC2')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,4)
    plot(data_(:,1),data_(:,5))
    ylabel('PC3')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,5)
    plot(data_(:,1),data_(:,6))
    ylabel('PC4')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,6)
    plot(data_(:,1),data_(:,7))
    ylabel('PC5')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,7)
    plot(data_(:,1),data_(:,8))
    ylabel('PC6')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,8)
    plot(data_(:,1),data_(:,9))
    ylabel('PC7')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,9)
    plot(data_(:,1),data_(:,10))
    ylabel('PC8')
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    subplot(10,1,10)
    plot(data_(:,1),data_(:,11))
    ylabel('PC9')
    set(gca,'ytick',[])
    xlabel('time [s]')

else
    period = 1/30;
    times = linspace(0,period*nframes,nframes);
    times = times';
    
    scores_ = scores;
    data = table(times, scores_(:,1),scores_(:,2),scores_(:,3),scores_(:,4), scores_(:,5), scores_(:,6), scores_(:,7), scores_(:,8), scores_(:,9), scores_(:,10));
    data = renamevars(data,'times','times [s]');
    
    data.Properties.VariableUnits = {'[s]','[K]','[K]','[K]','[K]','[K]','[K]','[K]','[K]','[K]','[K]'};
    
    degreeSymbol = char(176);
    newYlabels = ["time [s]","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10"];
    subplot(10,1,1)

end

% size(res_)
% size(scores_)

%plt = stackedplot(data,'Title','Stacked Data','DisplayLabels',newYlabels, 'XVariable','times [s]');

grid on;

filename = filename(1:end-4);

savefig(PC2, append(filename,'_PC2_','.fig'));
savefig(PC4, append(filename,'_PC4_','.fig'));
savefig(PC, append(filename,'_PC_','.fig'));
savefig(weigths, append(filename,'_pesi_','.fig'));
savefig(fig, append(filename,'_stackedPC_','.fig'));

%scores ha dimensioni: colonne -> componenti, di righe -> frames

if clustering == true
    [cluster_id, centroid_coordinates] = kmeans(scores(:,1:N_significant_PC),N_significant_PC);

    signPC = linspace(1,N_significant_PC,N_significant_PC);

    figure

    for i = 1:N_significant_PC
        hold on
        plot(signPC,centroid_coordinates(:,i));
    end
    hold off

    figure
    silhouette(scores(:,1:N_significant_PC),cluster_id)
end


end