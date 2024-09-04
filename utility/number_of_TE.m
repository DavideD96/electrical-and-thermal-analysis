cd termoFiles_mat\
ev=load('DD_matriceEventi.mat');
ev=ev.DD_matriceEventi;
cd ..

nev=0;

for ii = 1:size(ev,1)
    if max(ev{ii,3})>nev
        nev=max(ev{ii,3});
    end
end

nev