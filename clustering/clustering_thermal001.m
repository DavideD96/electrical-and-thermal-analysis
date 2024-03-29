function clustering_thermal001(filename,fileres,start_end, q, varargin)

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

check = exist(['clustering\',filename]);
if check ~= 7
    mkdir(['clustering\',filename]);
end
%save the folder path where save data
path = [pwd,'\clustering\',filename,'\',];

clustering = false;
N_significant_PC = 5;
use_electr = false;
interact = false;

num = size(varargin,2);

for k = 1:2:num
    if prod(varargin{k}=='kmean_clustering')
        clustering = varargin{k+1};
    elseif prod(varargin{k}=='N_significant_PC')
        N_significant_PC = varargin{k+1};
    elseif prod(varargin{k}=='add_electric_dat')
        use_electr = varargin{k+1};
    elseif prod(varargin{k}=='choose_twoPoints')
        interact = varargin{k+1};
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
[cluster_id, centres_coordinates] = kmeans(data_,q);
%[cluster_id, centres_coordinates] = dbscan(data_,sqrt(20*40*0.04),3);
%[cluster_id, centres_coordinates] = clusterdata(data_,4);

sil = figure;
silhouette(data_,cluster_id)

clust = figure;
if rem(q,3) == 0
    for i = 1:q/3
        for j = 1:3
            subplot(q/3,3,3*(i-1)+j);
            pc1 = reshape(centres_coordinates(3*(i-1)+j,:),[rows,col]);
            title_str = num2str(3*(i-1)+j);
            title(title_str);
            imagesc(pc1);
            xlim([1,col]);
            ylim([1,rows]);
            colorbar
            hold off;
        end
    end
else
    for i = 1:q
        subplot(1,q,i);
        pc1 = reshape(centres_coordinates(i,:),[rows,col]);
        title_str = num2str(i);
        title(title_str);
        imagesc(pc1);
        xlim([1,col]);
        ylim([1,rows]);
        colorbar
        hold off;
    end
end

cd clustering

sgtitle('clusters centroids')
savefig(sil, append(filename,'_silou__Nclust',num2str(q),'.fig'));
savefig(clust, append(filename,'_clust__Nclust',num2str(q),'.fig'));

if interact == true
    answer = inputdlg({'Da quale figura vuoi selezionare i punti?'});
    figure
    ans_ = str2double(cell2mat(answer));
    pc1 = reshape(centres_coordinates(ans_,:),[rows,col]);
    title_str = num2str(i);
    title(title_str);
    imagesc(pc1);
    [x,y]=ginput(2);
    coord = [x,y];
    save('points_coord.mat',"coord",'-mat')
end

cd ..                
end