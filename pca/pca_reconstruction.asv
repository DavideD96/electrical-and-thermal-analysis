function pca_reconstruction(filename,start_end)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

data = load(filename,'-mat');
data = cell2mat(struct2cell(data));

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
for i = starting_frame:starting_frame+nframes
    data_(i,:) = reshape(data(:,:,i),[1,rows*col]); 
end

%coeff sono i coefficienti delle componenti principali. Ogni colonna
%rappresenta una componente principale nella base delle osservabili fisiche
%originarie il numero massimo di coefficienti è pari al numero di pixel

%di default pca centra i dati, per cui i gradi di libertà massimi sono
%n-1, non n. Puoi anche impostare 'Centered',false
[coeff,scores,latent,tsquared,explained,mu1] = pca(data_);

cut = 4; %use 4 pc for reconstruction
coeff_cut = coeff(:,1:cut);
scores_cut = scores(:,1:cut);

video = 1;
path = 'reconstr_';

%variabili per video
if video == 1
    video_name = strcat('video.avi');

    vidObj = VideoWriter(append(path,video_name));
    vidObj.Quality = 100; % max (credo)
    vidObj.FrameRate = 30/10; %i dati della termocamera sono a 30 Hz
    open(vidObj);

    video_length = nframes;
    video_frameRate = 30;
    video_times = zeros(video_length,1);

    for i=1:video_length
        video_times(i) = (i-1)*1/video_frameRate;
    end

    f = figure('position',[200 100 1000 500]);
    load('ThermoColorMap1.mat');
end

axres = axes(f,'outerPosition', [0 0 0.3 1]); %subplot(1,3,1);
axtemp = axes(f,'outerPosition', [0.35 0 0.3 1]);
axdiff = axes(f,'outerPosition', [0.7 0 0.3 1]);

% figure
% reconstructed = reshape(scores_cut(1,:)*(coeff_cut(1,:))'+ repmat(mu1,1,1),[rows,col]);
% imagesc(reconstructed)
% hold off
reconstructed = zeros(rows,col,nframes);


for i = start_end(1):start_end(2)
    reconstructed(:,:,i) = reshape(scores_cut(i,:)*(coeff_cut(i,:))'+ repmat(mu1,1,1),[rows,col]);
end

for i = start_end(1):start_end(2)

    % reconstructed = reshape(scores_cut(i,:)*(coeff_cut(i,:))'+ repmat(mu1,1,1),[rows,col]);

    % a = scores_cut(i,:)*(coeff_cut(i,:))';
    % a(1,1)
    Tmin = min(min(data(:,:,i)));
    Tmax = max(max(data(:,:,i)));

    imagesc(data(:,:,i), 'Parent',axtemp);
    colormap(cm);
    clim(axtemp,[Tmin Tmax]);
    colorbar(axtemp);
    title(filename, 'Interpreter','none','Parent',axtemp);
    xlabel('[n° pixel]','Parent',axtemp);
    ylabel('[n° pixel]','Parent',axtemp);

    %[T_max,~] = max(abs(reconstructed));

    %zMin = -T_max;
    %zMax = T_max;
    %clim([zMin, zMax]);
    
    %surf(m_ridotta);
    %zlim([zMin, zMax])
    % 
    % Tmin = min(min(reconstructed(:,:,i)));
    % Tmax = max(max(reconstructed(:,:,i)));
    imagesc(reconstructed(:,:,i),'Parent',axdiff);
    colormap(cm);
    clim(axtemp,[Tmin Tmax]); %momentaneo ma sensato per fare cfr
    %clim(axdiff,[zMin, zMax]);
    title('reconstructed', 'Interpreter','none','Parent',axdiff);
    colorbar(axdiff);
    xlabel('[n° pixel]','Parent',axdiff);
    ylabel('[n° pixel]','Parent',axdiff);

    frame = getframe(gcf);        % costruisco il
    writeVideo(vidObj, frame);    % filmato  puoi usare im2frame(m,cm) al posto di frame

end
close(gcf);
close(vidObj);

clear S    %clear workspace    
pcaSignificance = explained;

weigths = figure;
plot(linspace(1,12,12), pcaSignificance(1:12));
xlabel('pca component');
ylabel('variance %');
grid on;
set(gca, 'XTick', 1:12)
end