function pc2 = pca_thermal006(filename,fileres, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-11-29 Last modification: 07/04/24
%
%Author: Davide Decastri
%perform pca analysis using detected events (but excluding multiple frames
%related to the same event), or all the frames together.
%
% filename: name of the Thermal file
% fileres: name of the file containing electric measurements
% start_end: start frame and end frame (e.g. [30,1200])
% varargin: 
%   'N_significant_PC' number of PCs to plot
%   'add_electric_dat' plot time evolution of PCs and conductance together
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd parameters\
par = load("ThermalParameters.mat");
par = par.ThermalParameters;
start_end = par.delay;
start_end = [start_end,par.end_stimulation];
cd ..

cd termoFiles_mat\

checkAS = 0;
select_point = 0;
nrighe = 4;
ncolonne = 4;
clustering = false;
N_significant_PC = 5;
use_electr = false;
smooth = false;
remove = 0;
remove_lr = 0;

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
    elseif prod(varargin{k}=='select_on_PC_num')
        pc_number = varargin{k+1};
    elseif prod(varargin{k}=='check_act_sites_')
        checkAS = varargin{k+1};
    elseif prod(varargin{k}=='_remove_up_down_')
        remove = varargin{k+1}
    elseif prod(varargin{k}=='_remove_lft_rig_')
        remove_lr = varargin{k+1}
    end
end

data = load(filename,'-mat');
data = cell2mat(struct2cell(data));

if any(remove)
    data = data(remove(1)+1:end-remove(2),:,:);
end

if any(remove_lr)
    data = data(:,remove_lr(1)+1:end-remove_lr(2),:);
end

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
pcaCSignificance = cumsum(pcaSignificance(1:20));
plot(linspace(1,20,20), pcaCSignificance);
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
%colormap(cm)
%figure

extrP = 0;
extrN = 0;

% for k = 1:ncolonne*nrighe
%     pc = reshape(coeff(:,k),[rows,col]);
%     test_P = max(pc,[],'all');
%     test_N = min(pc,[],'all');
%     if extrP < test_P
%         extrP = test_P;
%     end
%     if extrN > test_N
%         extrN = test_N;
%     end
% end
%figure
%t = tiledlayout(nrighe,ncolonne);

for k = 1:ncolonne*nrighe
    subplot(nrighe,ncolonne,k);
    %nexttile
    hold on;
    pc = reshape(coeff(:,k),[rows,col]);
    imagesc(pc); %flip
    title(append('PC',num2str(k)),"FontSize",14);
    xlim([1,col]);
    ylim([1,rows]);
    % clim([extrN,extrP])
    %axis off
    %axis equal
    %clim([-0.32,0.42])
    axis off
    hcb = colorbar;
    hold off;
    colormap("hot")
    % colorbarpos=hcb.Position;
    % %colorbarpos(3)=0.7*colorbarpos(3);
    % colorbarpos(4)=0.7*colorbarpos(4);
    % % %colorbarpos(2)=0.8*colorbarpos(2);
    % hcb.Position = colorbarpos;
end
figure
% figure
% for k = 1:ncolonne*nrighe/2
%     subplot(nrighe/2,ncolonne,k);
%     %nexttile
%     hold on;
%     pc = reshape(coeff(:,k+ncolonne*nrighe/2),[rows,col]);
%     title(append('PC',num2str(k+ncolonne*nrighe/2)));
%     imagesc(pc); %flip
%     xlim([1,col]);
%     ylim([1,rows]);
%     % clim([extrN,extrP])
%     axis off
%     colorbar;
%     hold off;
% end

% t.TileSpacing = 'compact';
% t.Padding = 'compact';

% figure
% subplot(2,6,1);
% hold on;
% %first principal component
% pc1 = reshape(coeff(:,1),[rows,col]);
% title('PC1');
% imagesc(flip(pc1,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,2);
% hold on;
% title('PC2');
% % %second principal component
% pc2 = reshape(coeff(:,2),[rows,col]);
% imagesc(flip(pc2,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,3);
% hold on;
% %third principal component
% pc3 = reshape(coeff(:,3),[rows,col]);
% title('PC3');
% imagesc(flip(pc3,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,4);
% hold on;
% %fourth principal component
% pc4 = reshape(coeff(:,4),[rows,col]);
% title('PC4');
% imagesc(flip(pc4,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,5);
% hold on;
% %fifth principal component
% pc5 = reshape(coeff(:,5),[rows,col]);
% title('PC5');
% imagesc(flip(pc5,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,6);
% hold on;
% %6th principal component
% pc6 = reshape(coeff(:,6),[rows,col]);
% title('PC6');
% imagesc(flip(pc6,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,7);
% hold on;
% %7th principal component
% pc7 = reshape(coeff(:,7),[rows,col]);
% title('PC7');
% imagesc(flip(pc7,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,8);
% hold on;
% %8th principal component
% pc8 = reshape(coeff(:,8),[rows,col]);
% title('PC8');
% imagesc(flip(pc8,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,9);
% hold on;
% %9th principal component
% pc9 = reshape(coeff(:,9),[rows,col]);
% title('PC9');
% imagesc(flip(pc9,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,10);
% hold on;
% %10th principal component
% pc10 = reshape(coeff(:,10),[rows,col]);
% title('PC10');
% imagesc(flip(pc10,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,11);
% hold on;
% %11th principal component
% pc11 = reshape(coeff(:,11),[rows,col]);
% title('PC11');
% imagesc(flip(pc11,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;
% 
% subplot(2,6,12);
% hold on;
% %12th principal component
% pc12 = reshape(coeff(:,12),[rows,col]);
% title('PC12');
% imagesc(flip(pc12,1));
% xlim([1,col]);
% ylim([1,rows]);
% axis off
% colorbar
% hold off;

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

% figure;
% hold on;
% %9th principal component
% pc1 = reshape(coeff(:,1),[rows,col]);
% title('pc1');
% imagesc(pc1);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc2 = reshape(coeff(:,2),[rows,col]);
% title('pc2');
% imagesc(pc2);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc3 = reshape(coeff(:,3),[rows,col]);
% title('pc3');
% imagesc(pc3);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc4 = reshape(coeff(:,4),[rows,col]);
% title('pc4');
% imagesc(pc4);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc5 = reshape(coeff(:,5),[rows,col]);
% title('pc5');
% imagesc(pc5);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc6 = reshape(coeff(:,6),[rows,col]);
% title('pc6');
% imagesc(pc6);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc7 = reshape(coeff(:,7),[rows,col]);
% title('pc7');
% imagesc(pc7);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc8 = reshape(coeff(:,8),[rows,col]);
% title('pc8');
% imagesc(pc8);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc9 = reshape(coeff(:,9),[rows,col]);
% title('pc9');
% imagesc(pc9);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc10 = reshape(coeff(:,10),[rows,col]);
% title('pc10');
% imagesc(pc10);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc11 = reshape(coeff(:,11),[rows,col]);
% title('pc11');
% imagesc(pc11);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% figure;
% hold on;
% %9th principal component
% pc12 = reshape(coeff(:,12),[rows,col]);
% title('pc12');
% imagesc(pc12);
% xlim([1,col]);
% ylim([1,rows]);
% axis equal
% colorbar
% hold off;
% 
% sgtitle('first principal components')
% 
% % figure
% % %7th principal component
% % pc7 = reshape(coeff(:,7),[rows,col]);
% % title('pc7');
% % imagesc(pc7);
% % colorbar
% 
% % %reconstruct frame 1
% % fr1 = reshape(scores(1,:)*coeff'+ repmat(mu1,1,1),[rows,col]); %i dati sono centrati, il numero di gradi di libertà è n-1
% % figure
% % title('fr1');
% % imagesc(fr1);
% % colorbar
% % 
% 
% PC2 = figure;
% imagesc(pc2);
% title('principal component 2')
% colorbar
% 
% PC4 = figure;
% imagesc(pc4);
% title('principal component 4')
% colorbar

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

%savefig(PC2, append(filename,'_PC2_','.fig'));
%savefig(PC4, append(filename,'_PC4_','.fig'));
savefig(PC, append(filename,'_PC_','.fig'));
savefig(weigths, append(filename,'_pesi_','.fig'));
%savefig(fig, append(filename,'_stackedPC_','.fig'));

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

if checkAS == 1

C = [];
listing = dir(pwd);
for ii = 1:length(listing)
    nome = listing(ii).name;
    if length(nome) > 5 && prod(nome(1:5) == 'group')
        x = nome(8);
        if nome(9) ~= '_'
            x = append(x,nome(9));
            y = nome(12);
            if nome(13) ~= '_'
                y = append(y,nome(13));
            end            
        else
            y = nome(11);
            if nome(12) ~= '_'
                y = append(y,nome(12));
            end   
        end
        x = str2num(x);
        y = str2num(y);

        C = [C; [x,y]]; 
    end
end

for ii = 1:12
    figure
    pc = reshape(coeff(:,ii),[rows,col]);
    imagesc(pc)
    axis equal
    hold on
    for kk = 1:size(C,1)
        plot(C(kk,2),C(kk,1),'w.', 'MarkerSize', 10);
    end
    title(append('pc ',num2str(ii)))
end
end

if select_point ~= 0
    coordinates = [];
    figure('Position',[200,100,900,900])
    pc = reshape(coeff(:,pc_number),[rows,col]);
    imagesc(pc)
    axis equal
    swapPc = {'1'};
    while swapPc{1} ~= '2'
        swapPc = inputdlg('swap pc? [0,1]. 2 to end');
        if swapPc{1} == '1'
            pc_number = pc_number + 1;
            pc = reshape(coeff(:,pc_number),[rows,col]);
            imagesc(pc)
            axis equal
        end

        hold on
        for kk = 1:size(coordinates,1)
            plot(coordinates(kk,2),coordinates(kk,1),'w.', 'MarkerSize', 12);
        end        
        [x,y] = ginput(1);
        coordinates = [coordinates;round([y,x])];
    end

    % g_coord = round([x,y]);
    %save(append("g_x",num2str(round(y)),"_y",num2str(round(x)),".mat"),"g_coord")
    close all
    for k = 1:size(coordinates,1)
        %cd ..
        cerca_punti_simili_2centresByUsr003(coordinates(k,:));
        %cd termoFiles_mat
    end

elseif prod(select_point == 'visual')

    nAS = 4;
    coord = zeros(nAS,2);

    for k=1:nAS

        str1 = append('g',num2str(k));
        fname = pwd;
        listing = dir(fname);  

        for j = 1:length(listing)
            str_complete = listing(j).name; 
            if size(strfind(str_complete,str1)) ~= 0
                strutt = load(str_complete);
                names = fieldnames(strutt); 
                coord(k,:) = strutt.(names{1});                
            end
        end
    end

    pc13 = reshape(coeff(:,13),[rows,col]);
    pc14 = reshape(coeff(:,14),[rows,col]);
    pc15 = reshape(coeff(:,15),[rows,col]);
    pc16 = reshape(coeff(:,16),[rows,col]);

    allpc = zeros(size(pc1,1),size(pc1,2),14);
    allpc(:,:,1) = pc1;
    allpc(:,:,2) = pc2;
    allpc(:,:,3) = pc3;
    allpc(:,:,4) = pc4;
    allpc(:,:,5) = pc5;
    allpc(:,:,6) = pc6;
    allpc(:,:,7) = pc7;
    allpc(:,:,8) = pc8;
    allpc(:,:,9) = pc9;
    allpc(:,:,10) = pc10;
    allpc(:,:,11) = pc11;
    allpc(:,:,12) = pc12;
    allpc(:,:,13) = pc13;
    allpc(:,:,14) = pc14;

    for ii = 1:16
        a = figure;
        title_name = append('Actve Sites ','pc',num2str(ii));
        imagesc(allpc(:,:,ii));
        hold on
        title(title_name)
        plot(coord(1,1),coord(1,2),'r+', 'MarkerSize', 20);
        plot(coord(2,1),coord(2,2),'r+', 'MarkerSize', 20);
        plot(coord(3,1),coord(3,2),'r+', 'MarkerSize', 20);
        plot(coord(4,1),coord(4,2),'r+', 'MarkerSize', 20);
        %plot(coord(5,1),coord(5,2),'g+', 'MarkerSize', 20);
        savefig(title_name)
        saveas(a, append(title_name,'.png'),'png');
    end
end
%cd ..
end