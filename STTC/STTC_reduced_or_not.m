function STTC_reduced_or_not(weighted_STTC,saveall,rangeMax,window)

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
        if prod(nome(1:5) == 'group') && ~contains(nome,'VS') && contains(nome,'.mat')
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
sttcs_red = [];
sttcs_rem = [];
dist = [];
x = [];

st_ = figure;
ax_st=axes('Parent',st_);
hold(ax_st,'on')
st_red = figure;
ax_st_red=axes('Parent',st_red);
hold(ax_st_red,'on')
st_rem = figure;
ax_st_rem=axes('Parent',st_rem);
hold(ax_st_rem,'on')


n_used_evts = 0;
cd termoFiles_mat
for ii = 1:ngroups
    group1 = load(groups{ii});
    group1 = group1.group1;  

    [x1,y1] = find_group_coord(groups{ii});

    if window ~= 0
        group1_red = group1(group1(:,1)<=window,:);
        check1_red = sum(group1_red(:,2));

        group1_rem = group1(group1(:,1)>window,:); %remaning
        check1_rem = sum(group1_rem(:,2));
    end

    check1 = sum(group1(:,2));
    group1 = groups{ii};

    if check1 ~= 0
        for kk = ii+1:ngroups
            group2 = load(groups{kk});
            group2 = group2.group1;

            if window ~= 0
                group2_red = group2(group2(:,1)<=window,:);
                check2_red = sum(group2_red(:,2)); %reducted

                group2_rem = group2(group2(:,1)>window,:);
                check2_rem = sum(group2_rem(:,2)); %remaining
            end

            check2 = sum(group2(:,2));
            group2 = groups{kk};

            if check2 ~= 0

                [x2,y2] = find_group_coord(groups{kk});
                %compute distance, IFOV = 25 micron
                dist_ = 25*sqrt((x1-x2)^2+(y1-y2)^2);

                if check1_red ~= 0 && check2_red ~= 0
                    [new_sttc,new_sttc_red,new_sttc_rem] = STTCmultiple_windows(group1,group2,[0.02,rangeMax],10,'plot_figure',saveall,'save_figure',saveall,'reduce_wind',window);
                else
                    [new_sttc,new_sttc_red,new_sttc_rem] = STTCmultiple_windows(group1,group2,[0.02,rangeMax],10,'plot_figure',saveall,'save_figure',saveall,'reduce_wind',0);                   
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
                %new_sttc_red
                sttcs = [sttcs,new_sttc_(:,2)];
                if ~isempty(new_sttc_red)
                    %hold(ax_st_red,'on')
                    sttcs_red = [sttcs_red,new_sttc_red(:,2)];
                    plot3(ax_st_red,dist_(1,1)*ones(size(new_sttc,1),1),new_sttc_red(:,1),new_sttc_red(:,2))
                end
                if ~isempty(new_sttc_rem) && sum(new_sttc_rem(:,2)) ~= 0
                    %hold(ax_st_rem,'on')
                    sttcs_rem = [sttcs_rem,new_sttc_rem(:,2)];
                    plot3(ax_st_rem, dist_(1,1)*ones(size(new_sttc,1),1),new_sttc_rem(:,1),new_sttc_rem(:,2))
                end
                dist = [dist,dist_];
                x = [x; x1,x2];
                %hold(ax_st,'on')
                %plot3(ax_st,dist_(1,1)*ones(size(new_sttc,1),1),new_sttc(:,1),new_sttc(:,2))
                dataPlot = [dist_(1,1)*ones(size(new_sttc,1),1),new_sttc(:,1),new_sttc(:,2),new_sttc(:,2)];
                T = array2table(dataPlot,'VariableNames',{'dist','time','sttc','sttc_col'});
                scatter3(ax_st,T,'dist','time','sttc','filled','ColorVariable','sttc_col')
            else
                warning(append(' no events in ',groups{kk}))
            end
        end
    else
        warning(append(' no events in ',groups{ii}))
    end
end

colorbar(ax_st)
axes(ax_st)
grid on

deltat = [2,4,20];

for ii = 1:size(deltat,2)
    figure
    dataPlot_correl1 = [x.*25, sttcs(deltat(ii),:)'];
    dataPlot_correl2 = [x(:,[2 1]).*25, sttcs(deltat(ii),:)'];
    
    dataPlot_correl = [dataPlot_correl1; dataPlot_correl2];
    
    a = array2table(dataPlot_correl,'VariableNames',{'x1','x2','sttc'});
    
    title_ = num2str(new_sttc(deltat(ii),1));
    plt = scatter3(a,'x1','x2','sttc','filled','ColorVariable','sttc');
    plt.SizeData = 100;
    title(['STTC at ',title_,' s'])
end

%hist3()

% figure
% [dist_ord,indices] = sort(dist,2,"ascend");
% sttcs = sttcs(:,indices);
% times = new_sttc(:,1);
% [X,Y] = meshgrid(times,dist_ord);


%scatter3(X,Y,sttcs','ColorVariable',sttcs')
% surf(X,Y,sttcs','FaceColor','none')
% ylabel('distance [\mum]')
% xlabel('\Deltat [s]')
% zlabel('STTC [adim.]')
% %txt = ['1' ' ' '4'];
% text(-times(end)/20,500,0,txt)
% grid on

cd ..


%mean sttc
if weighted_STTC == 1
    sttc_mean = sum(sttcs,2)/(n_used_evts); %size(sttcs,2)
else
    sttc_mean = mean(sttcs,2);
end
% plot(sttc_mean)

end