function engram2El(filename,folders)

%filename: togli anche il 00x

f_in = folders{1};
f_fin = folders{end};

in = str2double(f_in);
fin = str2double(f_fin);

history = [];

load('ThermoColorMap2.mat');

for ii = 1:length(folders)

    %3-6
    f = num2str(folders{ii});
    cd(f)
    cd termoFiles_mat\

    m36 = load("mtotalT.mat");
    m36 = m36.mtotalT;

    start = load("start_apply.mat");
    start = start.index;

    zer = '';
    for kk = 1:3-numel(num2str(folders{ii}))
        zer = [zer,'0'];
    end
    cd ..
    groove_coord = load([filename,'-',zer,num2str(folders{ii}),'_groove_coordinates.mat']);
    groove_coord = groove_coord.groove_coordinates;
    cd ..


    
    cold = mean(m36(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start-61:start-1),3);
    hot = mean(m36(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),start+1:start+61),3);
    mdiff1 = hot-cold;

    %size(history)
    %size(max(mdiff1,[],2))
    history = [history,max(mdiff1,[],2)];

    minim = min(mdiff1,[],'all');
    maxim = max(mdiff1,[],'all');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    rescaling = 70;

    % size(mdiff1,2)/rescaling
    % size(mdiff1,2)/(rescaling*ratio2(2))

    %maxsz = max([sz1,sz2,sz3],[],'all');

    %fig_ = figure('Position', [50,50,600,600]);
    %pixel_size = 1; % Puoi modificarlo se necessario

    %ax1 = subplot(1,3,1);
    %fig__ = figure('Position', [50,50,600,600]);
    %ax1 = axes(fig_,'Position', [0.1 0.1 size(mdiff1,2)/rescaling size(mdiff1,1)/rescaling]);
    %imagesc(ax1,mdiff1);
    %ax1.Position = [100 100 size(mdiff1,2)*2 size(mdiff1,1)*2];
    %get(gca,'CameraPosition')
    %set(gca,'Position',[3.5,19,40,60])


    axis image;
    clim([minim,maxim])
    %axis equal
    colormap(cm)
    colorbar

    close all
end

    %history36
    rescaling_ = rescaling/1.5;

    fig_ = figure('Position',[50,50,1000,700]);

    ax1 = axes(fig_);
    %subplot(3,1,1)
    %surf(history36)
    imagesc(history)
    colorbar
    %clim([min_,max_])
    view([0 90])

    save('history.mat',"history",'-mat')
end