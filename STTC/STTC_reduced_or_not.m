function STTC_reduced_or_not(weighted_STTC,saveall,rangeMax,window)

%Computes BD coefficient, defined as number of significant PC * mean STTC 
%groups = array of strings ["group_x7_y4","group_x2_y6","group_x5_y5","group_x1_y2"]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% sttc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_sampling = 200;
startDeltat = 0.05;

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
x_red = [];
x_rem = [];
n = []; %n eventi
n_red = [];
n_rem = [];

f1 = figure('Position',[50 50 1400 400]);
ax_st = subplot(1,3,1);
%ax_st=axes('Parent',st_);
hold(ax_st,'on')
%st_red = figure;
%ax_st_red=axes('Parent',st_red);
ax_st_red = subplot(1,3,2);
hold(ax_st_red,'on')
%st_rem = figure;
%ax_st_rem=axes('Parent',st_rem);
ax_st_rem = subplot(1,3,3);
hold(ax_st_rem,'on')


n_used_evts = 0;
cd termoFiles_mat
for ii = 1:ngroups
    group1 = load(groups{ii});
    group1 = group1.group1;  

    [x1,y1] = find_group_coord(groups{ii});

    if window ~= 0
        group1_red = group1(group1(:,1)<=window+group1(1,1),:);
        check1_red = sum(group1_red(:,2));

        group1_rem = group1(group1(:,1)>window+group1(1,1),:); %remaning
        check1_rem = sum(group1_rem(:,2));
    end

    check1 = sum(group1(:,2));
    group1 = groups{ii};

    if check1 ~= 0
        for kk = ii+1:ngroups
            group2 = load(groups{kk});
            group2 = group2.group1;

            if window ~= 0
                group2_red = group2(group2(:,1)<=window+group2(1,1),:);
                check2_red = sum(group2_red(:,2)); %reducted

                group2_rem = group2(group2(:,1)>window+group2(1,1),:);
                check2_rem = sum(group2_rem(:,2)); %remaining
            end

            check2 = sum(group2(:,2));
            group2 = groups{kk};

            if check2 ~= 0

                [x2,y2] = find_group_coord(groups{kk});
                %compute distance, IFOV = 25 micron
                dist_ = 25*sqrt((x1-x2)^2+(y1-y2)^2);

                % if check1_red ~= 0 && check2_red ~= 0
                [new_sttc,new_sttc_red,new_sttc_rem] = STTCmultiple_windows(group1,group2,[startDeltat,rangeMax],N_sampling,'plot_figure',saveall,'save_figure',saveall,'reduce_wind',window);
                % else
                %     [new_sttc,new_sttc_red,new_sttc_rem] = STTCmultiple_windows(group1,group2,[0.05,rangeMax],2,'plot_figure',saveall,'save_figure',saveall,'reduce_wind',0);                   
                % end

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
                if ~isempty(new_sttc_red) && sum(new_sttc_red(:,2)) ~= 0
                    %hold(ax_st_red,'on')
                    sttcs_red = [sttcs_red,new_sttc_red(:,2)];
                    %plot3(ax_st_red,dist_(1,1)*ones(size(new_sttc,1),1),new_sttc_red(:,1),new_sttc_red(:,2))
                    dataPlot_red = [dist_(1,1)*ones(size(new_sttc_red,1),1),new_sttc_red(:,1),new_sttc_red(:,2),new_sttc_red(:,2)];
                    T_red = array2table(dataPlot_red,'VariableNames',{'dist','time','sttc','sttc_col'});
                    scatter3(ax_st_red,T_red,'dist','time','sttc','filled','ColorVariable','sttc_col')
                    x_red = [x_red; x1,x2]; %per plot successivo della matrice
                end
                if ~isempty(new_sttc_rem) && sum(new_sttc_rem(:,2)) ~= 0
                    %hold(ax_st_rem,'on')
                    sttcs_rem = [sttcs_rem,new_sttc_rem(:,2)];
                    %plot3(ax_st_rem, dist_(1,1)*ones(size(new_sttc,1),1),new_sttc_rem(:,1),new_sttc_rem(:,2))
                    dataPlot_rem = [dist_(1,1)*ones(size(new_sttc_rem,1),1),new_sttc_rem(:,1),new_sttc_rem(:,2),new_sttc_rem(:,2)];
                    T_rem = array2table(dataPlot_rem,'VariableNames',{'dist','time','sttc','sttc_col'});
                    scatter3(ax_st_rem,T_rem,'dist','time','sttc','filled','ColorVariable','sttc_col')
                    x_rem = [x_rem; x1,x2];
                end
                dist = [dist,dist_];
                x = [x; x1,x2];

                n = [n; check1,check2];
                n_rem = [n_rem; check1_rem,check2_rem];
                n_red = [n_red; check1_red,check2_red];

                %hold(ax_st,'on')
                %new_sttc_rem
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

colorbar(ax_st_rem)
axes(ax_st_rem)
title(['remaining (',num2str(window),' s - end)'])
grid on
%savefig(['ALL_STTC_from_', num2str(window),'_s_to_end___dist.fig'])
%saveas(ax_st_rem,['ALL_STTC_from_', num2str(window),'_s_to_end___dist.png'],'png');

colorbar(ax_st_red)
axes(ax_st_red)
title(['reduced (0 s - ',num2str(window),' s)'])
grid on
%savefig(['ALL_STTC_from_start_to_', num2str(window),'_s___dist.fig'])
%saveas(ax_st_red,['ALL_STTC_from_start_to_', num2str(window),'_s___dist.png'],'png');

colorbar(ax_st)
axes(ax_st)

% ax_st.Position(1) = ax_st.Position(1)/2;
% ax_st.Position(3) = ax_st.Position(4);
% 
% ax_st_rem.Position(1) = ax_st_rem.Position(1)-ax_st.Position(1)*1/2;
% ax_st_rem.Position(3) = ax_st_rem.Position(4);
% 
% ax_st_red.Position(1) = ax_st_red.Position(1)-ax_st.Position(1)*1/2;
% ax_st_red.Position(3) = ax_st_red.Position(4);

title('all (0 s - end)')
grid on

savefig('ALL_STTC_dist.fig')
saveas(f1,'ALL_STTC_dist.png','png');

passo = rangeMax/N_sampling;
deltat = [0.1/passo,0.2/passo,0.5/passo,1/passo,5/passo,10/passo];
%deltat = [2,4,10,20,100,200];

thresh = 0.5;

%sttc: 
% rows = different deltat
% col = different couples

f2 = figure('Position',[50 50 1400 400]);

thr_sttc = subplot(1,3,1);
n_above_th = sum(sttcs>thresh,2); 

plot(thr_sttc,new_sttc(:,1),n_above_th)
grid on
title(['number over threshold (',num2str(thresh),')'])

thr_sttc_red = subplot(1,3,2);
n_above_th = sum(sttcs_red>thresh,2); 

plot(thr_sttc_red,new_sttc(:,1),n_above_th)
grid on
title(['number over threshold (',num2str(thresh),') reduced'])

thr_sttc_rem = subplot(1,3,3);
if size(sttcs_rem) ~= [0 0]
    n_above_th = sum(sttcs_rem>thresh,2); 
    plot(thr_sttc_rem,new_sttc(:,1),n_above_th)
    grid on
end

title(['number over threshold (',num2str(thresh),') remaining'])
savefig('n_over_threshold.fig')
saveas(f2,'n_over_threshold.png','png')

for ii = 1:size(deltat,2)

    f3 = figure('Position',[50 50 1400 400]);
    ax1 = subplot(1,3,1);

    dataPlot_correl1 = [x.*25, sttcs(deltat(ii),:)'];
    dataPlot_correl2 = [x(:,[2 1]).*25, sttcs(deltat(ii),:)'];
    
    dataPlot_correl = [dataPlot_correl1; dataPlot_correl2];

    a = array2table(dataPlot_correl,'VariableNames',{'x1','x2','sttc'});
    title_ = num2str(new_sttc(deltat(ii),1));
    plt = scatter3(ax1,a,'x1','x2','sttc','filled','ColorVariable','sttc');
    plt.SizeData = 100;
    title(['STTC at ',title_,' s'])        
    ax1.Position(1) = ax1.Position(1)/2;
    xlim(ax1,[0,2500])
    ylim(ax1,[0,2500])
    %axis equal

    for kk = 1:size(x,1)
        text(x(kk,1)*25-102,x(kk,2)*25,1.0,[num2str(n(kk,1)),'/',num2str(n(kk,2))],'FontSize',6)
    end
    %set(gca,'Position',[50, 50, 400, 400])
    ax1.Position(3) = ax1.Position(3)*1.3;
    ax1.Position(4) = ax1.Position(4)*1;
    %axis equal;
    colorbar
    view(2)
    %savefig(['ALL_STTC_at_',title_,'_s.fig'])
    %saveas(a1,['ALL_STTC_at_',title_,'_s.png'],'png');

    ax2 = subplot(1,3,2);
    dataPlot_correl1 = [x_red.*25, sttcs_red(deltat(ii),:)'];
    dataPlot_correl2 = [x_red(:,[2 1]).*25, sttcs_red(deltat(ii),:)'];
    
    dataPlot_correl = [dataPlot_correl1; dataPlot_correl2];
    
    a = array2table(dataPlot_correl,'VariableNames',{'x1','x2','sttc'});
    
    title_ = num2str(new_sttc_red(deltat(ii),1));
    plt = scatter3(ax2,a,'x1','x2','sttc','filled','ColorVariable','sttc');
    plt.SizeData = 100;
    title(['STTC reduced at ',title_,' s'])

    %ax1.Position(1) = ax1.Position(1)/2;
    
    for kk = 1:size(x,1)
        text(x(kk,1)*25-105,x(kk,2)*25,1.0,[num2str(n_red(kk,1)),'/',num2str(n_red(kk,2))],'FontSize',7)
    end
    %set(gca,'Position',[50, 50, 400, 400])
    ax2.Position(1) = ax2.Position(1)*0.94;
    ax2.Position(3) = ax2.Position(3)*1.3;
    ax2.Position(4) = ax2.Position(4)*1;

    xlim(ax2,[0,2500])
    ylim(ax2,[0,2500])
    %axis equal

    colorbar
    view(2)
    %savefig(['ALL_STTC_remaining_',num2str(window),'_s_at_',title_,'_s.fig'])
    %saveas(a2,['ALL_STTC_remaining_',num2str(window),'_s_at_',title_,'_s.png'],'png');

    ax3 = subplot(1,3,3);
    dataPlot_correl1 = [x_rem.*25, sttcs_rem(deltat(ii),:)'];
    dataPlot_correl2 = [x_rem(:,[2 1]).*25, sttcs_rem(deltat(ii),:)'];
    
    dataPlot_correl = [dataPlot_correl1; dataPlot_correl2];
    
    a = array2table(dataPlot_correl,'VariableNames',{'x1','x2','sttc'});
    
    title_ = num2str(new_sttc_rem(deltat(ii),1));
    plt = scatter3(ax3,a,'x1','x2','sttc','filled','ColorVariable','sttc');
    plt.SizeData = 100;
    title(['STTC remaining at ',title_,' s'])


    for kk = 1:size(x,1)
        % check_grafico = find(x(abs(x(kk,1)-x(1:kk-1,1))<8));
        % if size(check_grafico,1) ~= 0 %qualcuno è troppo vicino
        %     if x(kk,1)-x(1:check_grafico,1) < 0
        %         text(x(kk,1)*25-120,x(kk,2)*25,1.0,[num2str(n_rem(kk,1)),'/',num2str(n_rem(kk,2))],'FontSize',7)
        %     else                 
        %         text(x(kk,1)*25-80,x(kk,2)*25,1.0,[num2str(n_rem(kk,1)),'/',num2str(n_rem(kk,2))],'FontSize',7)
        %     end
        % 
        % else
            text(x(kk,1)*25-102,x(kk,2)*25,1.0,[num2str(n_rem(kk,1)),'/',num2str(n_rem(kk,2))],'FontSize',7)
        % end
    end
    ax3.Position(1) = ax3.Position(1)*1.05;
    ax3.Position(3) = ax3.Position(3)*1.3;
    ax3.Position(4) = ax3.Position(4)*1;

    xlim(ax3,[0,2500])
    ylim(ax3,[0,2500])
    %axis equal
    colorbar
    view(2)
end

savefig(['ALL_STTC_window_',num2str(window),'_s_at_',title_,'_s.fig'])
saveas(f3,['ALL_STTC_window_',num2str(window),'_s_at_',title_,'_s.png'],'png');

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