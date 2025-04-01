%computes cross correlogram betwee two series of RS events: per each RS in
%a serie computed dt respect to all the other RS events in the second
%serie.

cd termoFiles_mat

window_ = 60;
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
%cd ..

ngroups = length(groups);
tiledlayout(6,8);
%b = tiledlayout(6,8);

cumul_dt_red = [];
cumul_dt_rem = [];

for ii = 1:ngroups
    group1 = load(groups{ii});
    group1 = group1.group1;  

    [x1,y1] = find_group_coord(groups{ii});

    if window_ ~= 0
        group1_red = group1(group1(:,1)<=window_+group1(1,1),:);
        check1_red = sum(group1_red(:,2));

        group1_rem = group1(group1(:,1)>window_+group1(1,1),:); %remaning
        check1_rem = sum(group1_rem(:,2));

        istants1_red = group1_red(group1_red(:,2) == 1,:);
        istants1_rem = group1_rem(group1_rem(:,2) == 1,:);
    end

    for kk = ii+1:ngroups

        group2 = load(groups{kk});
        group2 = group2.group1;  

        group2_red = group2(group2(:,1)<=window_+group2(1,1),:);
        check2_red = sum(group2_red(:,2));

        group2_rem = group2(group2(:,1)>window_+group2(1,1),:); %remaning
        check2_rem = sum(group2_rem(:,2));        

        istants2_red = group2_red(group2_red(:,2) == 1,:);
        istants2_rem = group2_rem(group2_rem(:,2) == 1,:);

        
        for nn = 1:size(istants1_rem,1)

            if check1_rem ~= 0 && check2_rem ~= 0
                dt_rem = [];
                for mm = 1:size(istants2_rem,1)
                    dt_rem = [dt_rem,istants2_rem(mm)-istants1_rem(nn)];
                end
                cumul_dt_rem = [cumul_dt_rem,dt_rem];
            end
            % dt_red
            % nexttile    
            % histogram(dt_red, 20)
        end

        
        for nn = 1:size(istants1_red,1)
            if check1_red ~= 0 && check2_red ~= 0
                dt_red = [];
                for mm = 1:size(istants2_red,1)
                    dt_red = [dt_red,istants2_red(mm)-istants1_red(nn)];
                end
                cumul_dt_red = [cumul_dt_red,dt_red];
                % nexttile    
                % histogram(dt_red, 20)
            end
        end

    end



    % figure
    % histogram(dt_rem)
end

figure
histogram(cumul_dt_red,30)
title('reduced')

figure
histogram(cumul_dt_rem,30)
title('remaining')
cd .. 