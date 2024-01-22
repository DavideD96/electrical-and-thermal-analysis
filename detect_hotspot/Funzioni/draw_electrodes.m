function draw_electrodes(frame)
    cd termoFiles_mat
    mtotalT = load('mtotalT.mat');
    mtotalT = cell2mat(struct2cell(mtotalT));
    [zmin, zmax] = bounds(mtotalT, "all"); %metto imrec o mdiff per i limiti??????
    cd ..
    figure
    
    size (mtotalT)
    imagesc(mtotalT(:,:,frame));
    hold on
    set(gca, 'YDir', 'normal')
    clim([15 zmax]);
    colormap("jet");
    colorbar;
    [x1, y1] = getline(gcf, 'closed');
    plot(x1(:,1), y1(:,1), "-o", "LineWidth", 4, "Color", "black", "MarkerFaceColor", "white")

    [x2, y2] = getline(gcf, 'closed');                   
    plot(x2(:,1), y2(:,1), "-o", "LineWidth", 4, "Color", "black", "MarkerFaceColor", "white")

    [x3, y3] = getline(gcf, 'closed');
    plot(x3(:,1), y3(:,1), "-o", "LineWidth", 4, "Color", "black", "MarkerFaceColor", "white")

    [x4, y4] = getline(gcf, 'closed'    );
    plot(x4(:,1), y4(:,1), "-o", "LineWidth", 4, "Color", "black", "MarkerFaceColor", "white")

    [x5, y5] = getline(gcf);
     plot(x5(:,1), x5(:,1), "-o", "LineWidth", 4, "Color", "black", "MarkerFaceColor", "white")
    
    hold off

    coordinate1 = [x1, y1];
    save("coordinate_elettrodi1.mat", "coordinate1");
    coordinate2 = [x2, y2];
    save("coordinate_elettrodi2.mat", "coordinate2");
    coordinate3 = [x3, y3];
    save("coordinate_elettrodi3.mat", "coordinate3");
    coordinate4 = [x4, y4];
    save("coordinate_elettrodi4.mat", "coordinate4");

    coordinate_film = [x5, y5];
    save("coordinate_elettrodi_film.mat", "coordinate_film");

end