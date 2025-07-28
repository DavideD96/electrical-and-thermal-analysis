load('Data.mat')
cd termoFiles_mat\
load('mtotalT.mat')
cd ..

cd('parameters')
load ThermalParameters.mat
cd ..

delay = ThermalParameters.delay;
ending = ThermalParameters.end_stimulation;
%history = reshape(max(mtot,[],2),[size(mtot,1),size(mtot,3),1]);

figure
plot(1./R(:,4))

npunti = 15;
threshold = 8;

title('select 2 far point (then you ll have the posibbility to resize again')
pause;
t1 = ginput(2);


pause
t = ginput(npunti-2);

%t = [t1;t];

t_res = linspace(0.05,size(R,1)/20,size(R,1));
%size(t_res)

reference = mtotalT(:,:,1:delay-20);
reference = mean(reference,3);

lastFr = size(mtotalT,3)-ending;
reference1 = mtotalT(:,:,end-lastFr+20:end);
reference1 = mean(reference1,3);

mtotalT = mtotalT(:,:,delay:end);
history = reshape(max(mtotalT,[],2),[size(mtotalT,1),size(mtotalT,3),1]);
t_hist = linspace(1,size(mtotalT,3)/50.5,size(mtotalT,3));

close all
figure
col = subplot(2,1,1);
imagesc(history);
%colorbar
res =subplot(2,1,2);
plot(t_res,1./R(:,4));

cond_vs_overthr = zeros(npunti,3);

for ii = 1:2
    xline(res,t1(ii,1)/20.1, 'r--', 'selected', 'LineWidth', 1);
    %(ending-delay)*50.2/20.1 - ((size(R,1)-t1(ii,1))*50.2/20.1)
    xline(col, (ending-delay) - ((size(R,1)-t1(ii,1))*50.2/20.1), 'r--', 'selected', 'LineWidth', 1);    
    ov_thresh = sum(mtotalT(:,:,round((ending-delay) - ((size(R,1)-t1(ii,1))*50.2/20.1)))-reference1>threshold,'all');
    cond = 1./R(round(t1(ii,1)),4);
    cond_vs_overthr(ii,:) = [t1(ii),cond,ov_thresh];
end

for ii = 3:npunti
    xline(res, round(t(ii-2,1)/20.1), 'r--', 'selected', 'LineWidth', 1);
    xline(col, round(t(ii-2,1)*50.2/20.1), 'r--', 'selected', 'LineWidth', 1);
    %round(t(ii,1)*50.2/19.8)
    %npixel over threshold
    ov_thresh = sum(mtotalT(:,:,round(t(ii-2,1)*50.2/20.1))-reference>threshold,'all');

    cond = 1./R(round(t(ii-2,1)),4);
    cond_vs_overthr(ii,:) = [t(ii-2),cond,ov_thresh];
    % figure
    % imagesc(mtotalT(:,:,round(t(ii,1)*51/20))-reference>threshold)
end

%cond_vs_overthr
figure
scatter(cond_vs_overthr(:,2),cond_vs_overthr(:,3))
xlabel('conductance [\Omega^{-1}]')
ylabel('pixel over threshold')

savefig('cond vs T')


load('ThermoColorMap2.mat');

figure
imagesc(mtotalT(:,:,round(t(2,1)*50.2/20.1))-reference)
colormap(cm)
colorbar

figure
imagesc(mtotalT(:,:,round(t(12,1)*50.2/20.1))-reference)
colormap(cm)
colorbar