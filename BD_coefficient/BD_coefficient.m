function BD_coefficient(groups,nframes,weighted_STTC)

%Computes BD coefficient, defined as number of significant PC * mean STTC 
%groups = array of strings ["group_x7_y4","group_x2_y6","group_x5_y5","group_x1_y2"]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% sttc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd parameters
start = load("ThermalParameters.mat");
start = start.ThermalParameters.delay;
cd ..

start_end = [start,start+nframes-1];

ngroups = length(groups);
sttcs = []; 

n_used_evts = 0;

for ii = 1:ngroups
    group1 = load(groups(ii));
    group1 = group1.group1;    
    check = sum(group1(:,2));
    group1 = groups(ii);

    if check ~= 0
        for kk = ii+1:ngroups
            group2 = load(groups(kk));
            group2 = group2.group1;
            check = sum(group2(:,2));
            group2 = groups(kk);
            if check ~= 0
                new_sttc = STTCmultiple_windows(group1,group2,[0.02,20],50,'plot_figure',1,'save_figure',0);
                if weighted_STTC == 1
                    g1 = load(group1);
                    g1 = g1.group1;
                    g2 = load(group2);
                    g2 = g2.group1;
                    new_events = sum(g1(:,2))+sum(g2(:,2));
                    n_used_evts = n_used_evts + new_events;
                    new_sttc = new_sttc.*new_events;
                end
                sttcs = [sttcs,new_sttc(:,2)];
            else
                warning(append('Warning: no events in '),group(kk))
            end
        end
    else
        warning(append('Warning: no events in '),group(ii))
    end
end

times = new_sttc(:,1);

%mean sttc
if weighted_STTC == 1
    sttc_mean = sum(sttcs,2)/(size(sttcs,2)*n_used_evts);
else
    sttc_mean = mean(sttcs,2);
end
% plot(sttc_mean)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  pca  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd termoFiles_mat
data = load('mtotalT.mat');
data = cell2mat(struct2cell(data));
cd ..

nframes = start_end(2)-start_end(1);
starting_frame = start_end(1);

[rows,col] = size(data,1,2);
data_ = zeros(nframes,rows*col);

%data_: nxp matrix. n sono le osservazioni (frames), p i pixel.
for i = 0:nframes-1
    data_(i+1,:) = reshape(data(:,:,starting_frame+i),[1,rows*col]); 
end

clear data

[~,~,~,~,explained,~] = pca(data_);
pcaSignificance = explained;
pcaCSignificance = cumsum(pcaSignificance(1:50));
pca_significative = pcaCSignificance<97.5;
pca_significative(pca_significative == 0) = []; 
npca_sign = length(pca_significative);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BD_coeff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BD_coefficient = sttc_mean.*npca_sign;

figure
plot(times,BD_coefficient)
grid on
xlabel('\DeltaT [s]')
ylabel('coefficient [adim.]')
end