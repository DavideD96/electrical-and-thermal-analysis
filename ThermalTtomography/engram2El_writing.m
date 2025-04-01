function engram2El_writing(filename,folders,comparison)

%filename: togli anche il 00x

%comparison = 1; %last pulse and reading

f_in = folders{1};
f_fin = folders{end};

in = str2double(f_in);
fin = str2double(f_fin);

history = [];

load('ThermoColorMap2.mat');
colormap(cm)

if comparison == 1
    hist_ = load("history.mat");
    hist_ = hist_.history;
end

for ii = 1:length(folders)

    %3-6
    f = num2str(folders{ii});
    cd(f)
    cd termoFiles_mat\

    m36 = load("mtotalT.mat");
    m36 = m36.mtotalT;
    % 
    % start = load("start_apply.mat");
    % start = start.index;

    zer = '';
    for kk = 1:3-numel(num2str(folders{ii}))
        zer = [zer,'0'];
    end
    cd ..
    groove_coord = load([filename,'-',zer,num2str(folders{ii}),'_groove_coordinates.mat']);
    groove_coord = groove_coord.groove_coordinates;


    CAF = m36(groove_coord(2,2):groove_coord(3,2),groove_coord(1,1):groove_coord(2,1),:);

    %size(history)
    %size(max(mdiff1,[],2))
    history = reshape(max(CAF,[],2),[size(CAF,1),size(CAF,3),1]);

    %hist__ = ones(size(history,1),30).*hist_(:,ii);

    % minim = min(mdiff1,[],'all');
    % maxim = max(mdiff1,[],'all');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    rescaling = 70;

    close all    
    rescaling_ = rescaling/1.5;

    fig_ = figure('Position',[50,50,1000,700]);

    ax1 = axes(fig_);
    %subplot(3,1,1)
    %surf(history36)
    if comparison == 1
        imagesc(history)
        title('select last pulse')
        pause
        lastpulse_position = ginput(1);

    end

    %tiledlayout(1,2)

    %nexttile
    imagesc(history)

    colormap(cm)
    colorbar
    ylabel('sample axis [pixel]')
    xlabel('frame')
    %clim([min_,max_])
    view([0 90])
    %nexttile
    %imagesc(hist__)
    %colormap(cm)    

    if comparison == 1
        lastPulse = history(:,round(lastpulse_position(1)));
        hist_ = hist_(:,ii)
        plot(lastPulse - hist_)
        
    end

    savefig(['train_history_f',folders{ii},'.fig'])
    saveas(fig_,['train_history_f',folders{ii},'.png'],'png')
    cd .. 
    end
end