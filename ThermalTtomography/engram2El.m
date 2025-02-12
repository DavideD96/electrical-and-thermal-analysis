function engram2El(filename,f_in,f_fin)

%filename: togli anche il 00x

in = str2double(f_in);
fin = str2double(f_fin);

history = [];

load('ThermoColorMap2.mat');

for ii = in:2:fin

    %3-6
    f = num2str(ii);
    cd(f)
    cd termoFiles_mat\

    m36 = load("mtotalT.mat");
    m36 = m36.mtotalT;

    start = load("start_apply.mat");
    start = start.index;

    zer = '';
    for kk = 1:3-numel(num2str(ii))
        zer = [zer,'0'];
    end
    
    cold = mean(m36(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start-61:start-1),3);
    hot = mean(m36(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start+1:start+61),3);
    mdiff1 = hot-cold;

    history36 = [history36,max(mdiff1,[],2)];

    min1 = min(mdiff1,[],'all');
    max1 = max(mdiff1,[],'all');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %3-8
    f = num2str(ii+1);
    cd(f)
    cd termoFiles_mat\

    m38 = load("mtotalT.mat");
    m38 = m38.mtotalT;

    start = load("start_apply.mat");
    start = start.index;

    zer = '';
    for kk = 1:3-numel(num2str(ii+1))
        zer = [zer,'0'];
    end

    cd ..
    groove_coord = load([filename,zer,num2str(ii+1),'_groove_b-c_3-8_coordinates.mat']);
    groove_coord = groove_coord.groove2_coordinates;
    cd ..
    
    cold = mean(m38(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start-61:start-1),3);
    hot = mean(m38(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start+1:start+61),3);
    mdiff2 = hot'-cold';

    history38 = [history38,max(mdiff2,[],2)];

    min2 = min(mdiff2,[],'all');
    max2 = max(mdiff2,[],'all');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %2-8
    f = num2str(ii+2);
    cd(f)
    cd termoFiles_mat\

    m28 = load("mtotalT.mat");
    m28 = m28.mtotalT;

    start = load("start_apply.mat");
    start = start.index;

    zer = '';
    for kk = 1:3-numel(num2str(ii+2))
        zer = [zer,'0'];
    end

    cd ..
    groove_coord = load([filename,zer,num2str(ii+2),'_groove_c-a_2-8_coordinates.mat']);
    groove_coord = groove_coord.groove3_coordinates;
    cd ..
    
    cold = mean(m28(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start-61:start-1),3);
    hot = mean(m28(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start+1:start+61),3);
    
    mdiff3 = hot'-cold';

    history28 = [history28,max(mdiff3,[],2)];

    min3 = min(mdiff3,[],'all');
    max3 = max(mdiff3,[],'all');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % 
    % 

    minim = min([min1,min2,min3]);
    maxim = max([max1,max2,max3]);

    sz1 = size(mdiff1);
    sz2 = size(mdiff2);
    sz3 = size(mdiff3);

    ratio2 = sz1./sz2;
    ratio3 = sz1./sz3;

    rescaling = 70;

    % size(mdiff1,2)/rescaling
    % size(mdiff1,2)/(rescaling*ratio2(2))

    %maxsz = max([sz1,sz2,sz3],[],'all');

    fig_ = figure('Position', [50,50,600,600]);
    pixel_size = 1; % Puoi modificarlo se necessario

    %ax1 = subplot(1,3,1);
    %fig__ = figure('Position', [50,50,600,600]);
    ax1 = axes(fig_,'Position', [0.1 0.1 size(mdiff1,2)/rescaling size(mdiff1,1)/rescaling]);
    imagesc(ax1,mdiff1);
    %ax1.Position = [100 100 size(mdiff1,2)*2 size(mdiff1,1)*2];
    %get(gca,'CameraPosition')
    %set(gca,'Position',[3.5,19,40,60])


    axis image;
    clim([minim,maxim])
    %axis equal
    colormap(cm)
    colorbar
    title('3-6')


    %subplot(1,3,2)
    ax2 = axes(fig_,'Position', [0.3 0.1 size(mdiff1,2)/(rescaling*ratio2(2)) size(mdiff1,1)/(rescaling*ratio2(1))]);
    imagesc(ax2,mdiff2);

    axis image;
    clim([minim,maxim])
    %axis equal
    colormap(cm)
    colorbar
    title('3-8 90deg')

    %subplot(1,3,3)
    ax3 = axes(fig_,'Position', [0.6 0.1 size(mdiff1,2)/(rescaling*ratio3(2)) size(mdiff1,1)/(rescaling*ratio3(1))]);
    imagesc(ax3,mdiff3);

    axis image;
    clim([minim,maxim])
    %axis equal
    colormap(cm)
    colorbar
    title('2-8 90deg')

    ax1.Position = [0.1 0.1 size(mdiff1,2)/rescaling size(mdiff1,1)/rescaling];
    ax2.Position = [0.35 0.1 size(mdiff1,2)/(rescaling*ratio2(2)) size(mdiff1,1)/(rescaling*ratio2(1))];
    ax3.Position = [0.7 0.1 size(mdiff1,2)/(rescaling*ratio3(2)) size(mdiff1,1)/(rescaling*ratio3(1))];

    %savefig(['engram_state_',num2str(ii)])
    close all
end

    %history36
    rescaling_ = rescaling/1.5;

    max_ = max([history28;history38;history36],[],'all');
    min_ = min([history28;history38;history36],[],'all');

    fig_ = figure('Position',[50,50,1000,700]);

    ax1 = axes(fig_);
    %subplot(3,1,1)
    %surf(history36)
    imagesc(history36)
    colorbar
    clim([min_,max_])
    view([0 90])

    %subplot(3,1,2)
    ax2 = axes(fig_);
    %surf(history38)
    imagesc(history38)
    colorbar
    clim([min_,max_])
    view([0 90])

    %subplot(3,1,3)
    ax3 = axes(fig_);
    %surf(history28)
    imagesc(history28)
    colorbar
    clim([min_,max_])
    view([0 90])

    save('engram36.mat',"history36",'-mat')
    save('engram38.mat',"history38",'-mat')
    save('engram28.mat',"history28",'-mat')

    ax1.Position = [0.1 0.67 size(history36,2)/rescaling_ size(history36,1)/rescaling_/4];
    ax2.Position = [0.1 0.30 size(history36,2)/rescaling_ size(history36,1)/rescaling_/ratio2(1)/4];
    ax3.Position = [0.1 0.1 size(history36,2)/rescaling_ size(history36,1)/rescaling_/ratio3(1)/4];
end