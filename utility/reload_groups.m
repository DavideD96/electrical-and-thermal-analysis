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

for ii = 1:size(groups,1)
    [x1,y1] = find_group_coord(groups{ii});
    cerca_punti_simili_2centresByUsr003([x1,y1]);
end