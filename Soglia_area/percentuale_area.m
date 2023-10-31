%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendi dati
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'E4_41_1mmx2mm_pome2_em0_89_fr30_V4_f11_1_1600__';
frame_start = 717;
fr_diff = 5;
coordname = 'E4_41_1mmx2mm_pome2_em0_89_fr30_V4_f11_1_1600__CAF_coordinates.mat';
type = 1;
smooth = 1;

[m1, mdiff] = get_data(filename, frame_start, fr_diff, coordname);
soglia_max = 0.3;
soglia_min = -0.3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%massimi e minimi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[max_hotspot, min_hotspot, z] = hotspot_3(mdiff, soglia_max, soglia_min, 'smoothing', smooth);
P = {max_hotspot, min_hotspot};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%selezione massimi e minimi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if type == 1
    %seleziono massimo assoluto
    p_max = sortrows(P{1,1}, 2, 'descend');
    
    %Costruisco S_max
    [peak, point_state_max] = primi_vicini(p_max(1,:), 1, mdiff);
    S_peak = {peak, point_state_max};

%MINIMO ASSOLUTO
%controllo se ci sono dati o è vuota
elseif type == 0
    %seleziono minimo assoluto
    p_min = sortrows(P{1,2}, 2, 'ascend');
    
    %Costruisco S_min
    [peak, point_state_min] = primi_vicini(p_min(1,:), 0,  mdiff);
    S_peak = {peak, point_state_min};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Analisi DWT e calcolo area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%scelta parametri DWT
wname = 'db4';
level =1;

%decomposizione
[C, S] = wavedec2(mdiff, level, wname);

%ricostruzione immagine
imrec = wrcoef2("a",C,S,wname,level);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%area al variare della soglia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perc_soglia = 0.2;
soglia_percA = zeros(0,2);

[Rows, Columns] = size (mdiff);
one_mat = ones(Rows, Columns);
area_tot = bwarea(one_mat);

while perc_soglia <= 1
%%controllo prima se c'è un massimo o un minimo       
        RS = regional_growth_segmentation_2(S_peak{1,1}, type, imrec, perc_soglia);
        perc_soglia = perc_soglia + 0.05;

        area = bwarea(RS);
        percA = area / area_tot;

        soglia_percA(end+1, :) = [perc_soglia, percA];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%grafico (percentuale area) vs (soglia percentuale)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(1,2,1)
hold on
    plot(soglia_percA(:,1), soglia_percA(:,2));
    title('Area/Area(tot) vs soglia percentuale');
    xlabel('soglia percentuale');
    ylabel('Area percentuale');
hold off


T_max_aus = zeros(size((mdiff),2),1);
ind_row = zeros(size(mdiff,2),1);
[Rows, Columns] = size (mdiff);
for k = 1:size(mdiff,2)
    [T_max_aus(k),ind_row(k)] = max(abs(mdiff(k,:)));
end
[T_max,ind_col] = max(T_max_aus);
zMin = -T_max;
zMax = T_max;

[Rows, Columns] = size (mdiff);
y = ceil(S_peak{1,1}(1,1)/Rows); %%floor up
x = S_peak{1,1}(1,1) - Rows*(y-1);

load('ThermoColorMap1.mat');

subplot(1,2,2)
hold on
    imagesc(imrec)
    set(subplot(1,2,2), 'YDir', 'normal')
    colormap(subplot(1,2,2),'gray')
    colorbar(subplot(1,2,2));
    plot(y, x, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'blue'); 
    title('DWT del frame in esame');
hold off
