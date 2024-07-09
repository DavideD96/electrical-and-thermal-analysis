function pc2 = pca_thermal004(filename,fileres,start_end, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-29 Last modification: -
%
%Author: Davide Decastri
%perform pca analysis using detected events (but excluding multiple frames
%related to the same event), or all the frames together.
%
% filename: name of the Thermal file
% fileres: 'Data.mat'
% start_end: [frame start, frame end]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clustering = false;
N_significant_PC = 5;
use_electr = false;
smooth = false;
nrighe = 3;
ncolonne = 4;

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
    elseif prod(varargin{k}=='select_STTCpoint')
        select_point = varargin{k+1};
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
colormap(winter)

figure(1);
clf();
hold on;

% Get the width and height of the figure
lbwh = get(1, 'position');
figw = lbwh(3);
figh = lbwh(4);

ncols = 6;
nrows = 2;

% for ii = 1:6
% 
%     % w and h of each axis in normalized units
%     axisw = (1 / ncols) * 0.95;
%     axish = (1 / nrows) * 0.95;
% 
%     row = floor( ii/(ncols+1) ) + 1;
%     col_ = mod( ii-1, ncols ) + 1;
% 
%     % calculate the left, bottom coordinate of this subplot
%     axisl = (axisw+0.02) * (col_-1);
%     axisb = (axish+0.02) * (row-1);
% 
%     %  plot the subplot
%     h= subplot('position', [axisl, axisb, axisw, axish] ); 
%     hold on;
%     %first principal component
%     pc1 = reshape(coeff(:,ii),[rows,col]);
%     title_ = ['PC',num2str(ii)];
%     title(title_);
%     imagesc(flip(pc1',1));
%     %imshow(flip(pc1',1)); 
%     xlim([1,col]);
%     ylim([1,rows]);
%     axis off
%     colorbar
%     hold off;
%     pause
% end

sgtitle('first principal components')
figure
for k = 1:ncolonne*nrighe
    subplot(nrighe,ncolonne,k);
    hold on;
    pc = reshape(coeff(:,k),[rows,col]);
    title(append('PC',num2str(k)));
    imagesc(flip(pc,1));
    xlim([1,col]);
    ylim([1,rows]);
    axis off
    colorbar
    hold off;
end

% size(res_)
% size(scores_)

%plt = stackedplot(data,'Title','Stacked Data','DisplayLabels',newYlabels, 'XVariable','times [s]');

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

if select_point == 1
    pc2disp = inputdlg({'select a PC'});
    figure
    pc1 = reshape(coeff(:,str2double(pc2disp{1})),[rows,col]);
    imagesc(pc1);
    pause
    [x,y] = ginput(1);
    coord = [round(x),round(y)];
    save(append('coord_x',num2str(round(x)),'_y',num2str(round(y)),'.mat'),"coord",'-mat');
end

m = load("mtotalT.mat");
m = m.mtotalT;
imagesc(m(:,:,331))

end