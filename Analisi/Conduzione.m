function Conduzione(frame)
    cd termoFiles_mat
    mtotalT = load('mtotalT.mat');
    mtotalT = cell2mat(struct2cell(mtotalT));
    cd ..

    [zmin, zmax] = bounds(mtotalT(:,:,frame), "all"); %metto imrec o mdiff per i limiti??????
    
    subplot(1,2,1)
    load('ThermoColorMap1.mat');
    imagesc(mtotalT(:,:,frame));
    set(gca, 'YDir', 'normal')
    clim([15 zmax]);
    
    colormap(cm);
    colorbar(subplot(1,2,1));  
end

