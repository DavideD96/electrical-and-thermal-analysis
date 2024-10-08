mtotalDT = load("mtotalDT.mat"); %mtotalDT has Nframes - fr_diff elements 
mtotalDT = cell2mat(struct2cell(mtotalDT));

load('ThermoColorMap1.mat');
frameDT = 347;

level = 1;
wname = 'db4';
mdiff = mtotalDT(:,:,frameDT);

[C, S] = wavedec2(mdiff, level, wname);

%ricostruzione immagine
imrec = wrcoef2("a",C,S,wname,level);

limits = [-1.35,2.55];
f1 = figure;
surf(mdiff)
colormap(cm)
colorbar
zlim(limits)
clim(limits)
xlabel('pixel in x-direction')
ylabel('pixel in y-direction')
zlabel('\DeltaT [°C]')
set(gca,'FontSize',18)
f1.Position = [10 10 1000 800];
if h(3)==1
      set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
else
      set(gca,'DataAspectRatio',[1 1 h(3)])
end

f2 = figure;
surf(imrec)
colormap(cm)
colorbar
zlim(limits)
clim(limits)
xlabel('pixel in x-direction')
ylabel('pixel in y-direction')
zlabel('\DeltaT [°C]')
%'Faces',[1 2 3 4],'Vertices',[18,39,0.5;1,39,0.5;1,1,0.5;18,1,0.5]
%h1 = patch('Faces',[1 2 3 4],'Vertices',[18,41,0.5;1,41,0.5;1,1,0.5;18,1,0.5]);
%h2 = patch('Faces',[1 2 3 4],'Vertices',[18,41,-0.5;1,41,-0.5;1,1,-0.5;18,1,-0.5]);
%h1.FaceAlpha = 1/3;
%h2.FaceAlpha = 1/3;
set(gca,'FontSize',18)
f2.Position = [10 10 1000 800];
if h(3)==1
      set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
else
      set(gca,'DataAspectRatio',[1 1 h(3)])
end

f3 = figure;
surf(imrec)
colormap(cm)
colorbar
zlim(limits)
clim(limits)
xlabel('pixel in x-direction')
ylabel('pixel in y-direction')
zlabel('\DeltaT [°C]')
%'Faces',[1 2 3 4],'Vertices',[18,39,0.5;1,39,0.5;1,1,0.5;18,1,0.5]
%h1 = patch('Faces',[1 2 3 4],'Vertices',[18,41,0.5;1,41,0.5;1,1,0.5;18,1,0.5]);
%h2 = patch('Faces',[1 2 3 4],'Vertices',[18,41,-0.5;1,41,-0.5;1,1,-0.5;18,1,-0.5]);
%h1.FaceAlpha = 1/3;
%h2.FaceAlpha = 1/3;
hold on
thrPos = 0.7*ones(size(mdiff));
thrNeg = -thrPos;
surf(thrNeg,'FaceColor','k', 'FaceAlpha',0.5, 'EdgeColor','none')
surf(thrPos,'FaceColor','k', 'FaceAlpha',0.5, 'EdgeColor','none')

h = get(gca,'DataAspectRatio') ;
if h(3)==1
      set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
else
      set(gca,'DataAspectRatio',[1 1 h(3)])
end
%title('Axis equal')

hold off
set(gca,'FontSize',18)
f3.Position = [10 10 1000 800];

