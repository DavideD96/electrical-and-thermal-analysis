%x = imread('gray.tif');
%[x_m, map] = gray2ind(x,20);
%plot(x);
%title('Immagine originale');

%decomposizione segnale
wname = 'db4';
level =1;
imor = mdiff;
T_max_aus = zeros(size(m1,2),1);
ind_row = zeros(size(m1,2),1);
for k = 1:size(m1,1)
    [T_max_aus(k),ind_row(k)] = max(abs(mdiff(k,:)));
end

[T_max,ind_col] = max(T_max_aus);
zMin = -T_max;
zMax = T_max;

clim([zMin, zMax]);

%immagine del segnale
figure (1)
subplot(2, 3, 1)
imagesc(imor)
colormap('gray')
colorbar;
title('immagine originale')
 
[C, S] = wavedec2(imor, level, wname);

%coefficienti
A = appcoef2(C, S, wname);
subplot(2, 3, 2)
imagesc(A)
colormap('gray')
colorbar;
title('immagine approssimata')


[H1,V1,D1] = detcoef2('all',C,S,1);

subplot(2, 3, 3)
colormap('gray')
imagesc(H1)
colormap('gray')
colorbar;
title('dettaglio orizzontale');

subplot(2, 3, 4)
imagesc(V1)
colormap('gray')
colorbar;
title('dettaglio verticale');

subplot(2, 3, 5)
imagesc(D1)
colormap('gray')
colorbar;
title('dettaglio diagonale');


%ricostruzione del segnale con i soli coefficienti di approsimazione
imrec = wrcoef2("a",C,S,wname,level);
subplot(2, 3, 6)
imagesc(imrec)
colormap('gray')
colorbar;
title('immagine ricostruita con i coefficienti di approssimazione');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%threshold
[thr,sorh,keepapp] = ddencmp('den', 'wv', imrec);
imden = wdencmp('gbl',imrec,wname,level,thr,'h',keepapp);


figure
subplot(1,2,1)
imagesc(imrec)
colorbar;
title('immagine ricostruita')

subplot(1,2,2)
imagesc(imden)
colormap('gray')
colorbar;
title('immagine ripulita')

figure
subplot(1,3,1)
BW1 = edge(imrec,'Canny'); %tra imrec e imden non cambia molto
imagesc(BW1)
colormap('gray')
colorbar;
title('bordi')

subplot(1,3,2)
BWdfill = imfill(BW1,'holes');
imagesc(BWdfill)
colormap('gray')
colorbar;
title('rimepimento')


%subplot(1,3,3)
%imsov=labeloverlay(imrec,BWdfill); %per sovrapposizione immagine
%imagesc(imsov)
%title('sovrapposizone')

