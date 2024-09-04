function STTC_reduced_or_not(weighted_STTC,saveall,window)

%Computes BD coefficient, defined as number of significant PC * mean STTC 
%groups = array of strings ["group_x7_y4","group_x2_y6","group_x5_y5","group_x1_y2"]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% sttc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%window = 30;

cd termoFiles_mat
listing = dir(pwd);
nfiles = length(listing);
groups = {};

for ii = 1:nfiles
    nome = listing(ii).name;
    if length(nome) > 4
        if prod(nome(1:5) == 'group') && ~contains(nome,'VS')
            groups = [groups;nome];
        end
    end
end
cd ..
%groups

cd parameters
start = load("ThermalParameters.mat");
end_ = start.ThermalParameters.end_stimulation;
start = start.ThermalParameters.delay;
cd ..

start_end = [start,end_];

ngroups = length(groups);
sttcs = []; 

n_used_evts = 0;
cd termoFiles_mat
for ii = 1:ngroups
    group1 = load(groups{ii});
    group1 = group1.group1;  

    if window ~= 0
        group1_red = group1(group1(:,1)<=window,:);
        check1_red = sum(group1_red(:,2));

        group1_rem = group1(group1(:,1)>window,:); %remaning
        check1_rem = sum(group1_rem(:,2));
    end

    check = sum(group1(:,2));
    group1 = groups{ii};

    if check ~= 0
        for kk = ii+1:ngroups
            group2 = load(groups{kk});
            group2 = group2.group1;

            if window ~= 0
                group2_red = group2(group2(:,1)<=window,:);
                check2_red = sum(group2_red(:,2));

                group2_rem = group2(group2(:,1)>window,:);
                check2_rem = sum(group2_rem(:,2));
            end

            check = sum(group2(:,2));
            group2 = groups{kk};
            if check ~= 0

                if check1_red ~= 0 && check2_red ~= 0
                new_sttc = STTCmultiple_windows(group1,group2,[0.02,20],50,'plot_figure',saveall,'save_figure',saveall,'reduce_wind',window);
                else
                    new_sttc = STTCmultiple_windows(group1,group2,[0.02,20],50,'plot_figure',saveall,'save_figure',saveall,'reduce_wind',0);
                end

                new_sttc_ = new_sttc;
                if weighted_STTC == 1
                    g1 = load(group1);
                    g1 = g1.group1;
                    g2 = load(group2);
                    g2 = g2.group1;
                    new_events = sum(g1(:,2))*sum(g2(:,2));
                    n_used_evts = n_used_evts + new_events; %partition function
                    new_sttc_ = new_sttc.*new_events;
                end
                sttcs = [sttcs,new_sttc_(:,2)];
            else
                warning(append(' no events in ',groups{kk}))
            end
        end
    else
        warning(append(' no events in ',groups{ii}))
    end
end
cd ..
times = new_sttc(:,1);

%mean sttc
if weighted_STTC == 1
    sttc_mean = sum(sttcs,2)/(n_used_evts); %size(sttcs,2)
else
    sttc_mean = mean(sttcs,2);
end
% plot(sttc_mean)


end