function emissivity_comparison(frame)

%importante! inizia sempre a selezionare dall'angolo in alto a sinistra.

load('ThermoColorMap1.mat');
colormap(cm);

%load 
m = load("mtotalT.mat");
m = m.mtotalT;

if exist("CAFcomp_coordinates1.mat","file") == 0
    imagesc(m(:,:,frame));
    title('set CAF1 area')
    pause;

    %[x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF
    [x,y] = ginput(2); %top left bottom right
    coordinates1 = [x,y];
    coordinates1 = [coordinates1;x(2),y(2)];
    coordinates1(2,:) = [x(2),y(1)];
    
    matfilename=sprintf('CAFcomp_coordinates1.mat');
    save(matfilename,'coordinates1');
    
    imagesc(m(:,:,frame));
    title('set CAF2 area')
    pause;
    
    %[x,y]=ginput(3); % select the left top corner, top right corner and the right bottom corner of the CAF
    [x,y] = ginput(2); %top left bottom right
    coordinates2 = [x,y];
    coordinates2 = [coordinates2;x(2),y(2)];
    coordinates2(2,:) = [x(2),y(1)];
    
    matfilename=sprintf(append('CAFcomp_coordinates2.mat'));
    save(matfilename,'coordinates2');
else
    coordinates1 = load("CAFcomp_coordinates1.mat");
    coordinates1 = coordinates1.coordinates1;

    coordinates2 = load("CAFcomp_coordinates2.mat");
    coordinates2 = coordinates2.coordinates2;
end
surf(mean(m(round(coordinates2(2,2)):round(coordinates2(3,2)),round(coordinates2(1,1)):round(coordinates2(2,1))),3))
hold on
surf(mean(m(round(coordinates1(2,2)):round(coordinates1(3,2)),round(coordinates1(1,1)):round(coordinates1(2,1))),3))
zlabel('Intensity (')
end