function hotspot (filename, fr_evento, fr_diff, soglia_max, soglia_min, coordname, set_area)
%Cartella per salvataggio dati
check = exist(['ThermoResults\',filename]);
if check ~= 7
    mkdir(['ThermoResults\',filename]);
end

path = [pwd,'\ThermoResults\',filename,'\',];

%set plot e carica mappa colori
figure (1)
hold on
set(gcf, 'Color','white')

load('ThermoColorMap1.mat');

%seleziona area
m1=readtable(sprintf(append(filename,'%d.CSV'),floor(10)),'Range','B9:XQ488');
m1= m1{:,:};

CAF_coord = load(coordname);
x = CAF_coord.coordinates(:,1);
y = CAF_coord.coordinates(:,2);

y_bl = (round(y(3))-round(y(2)))+round(y(1));
x_bl = round(x(3))-(round(x(2))-round(x(1)));

if round(y(1)) >= round(y(2))
    boundaries = parallelogrammas_boundary2(480, 'l',[x(1),y(1)], 't',[x(2),y(2)], 'r',[x(3),y(3)], 'b',[x_bl,y_bl]); %left-top is the free egde of the CAF
else
    boundaries = parallelogrammas_boundary2(480, 'l',[x_bl,y_bl], 't',[x(1),y(1)], 'r',[x(2),y(2)], 'b',[x(3),y(3)]);
end

y_ridotta = round(y_bl)-round(y(2));
x_ridotta = round(x(3))-round(x(1));
m1_ridotta = zeros(y_ridotta+10,x_ridotta+10);
    n = fr_evento;

%salva dati
for k = 1 : 2
    m1=readtable(sprintf(append(filename,'%d.CSV'), n),'Range','B9:XQ488'); %dimentions = (480x640)
    m1 = m1{:,:};
    
    %%%%%%%% store data %%%%%%%%%
    n_pixel = 0;
    
    for i=1:480 %righe    
        for j=1:640 %colonne
            if j >= boundaries(i,1) && j <= boundaries(i,2)
                n_pixel = n_pixel + 1;

                m1_ridotta(i-round(y(2))+6,j-round(x(1))+6) = m1(i,j);
            end
        end
    end
    frames(k,1) = {m1_ridotta};
    n = fr_evento + fr_diff;
end


%Grafico
%axdiff = axes(f,'outerPosition', [0.5 0 0.3 1]);
m1 = frames{1, 1};
m2 = frames{2, 1};
mdiff = m2-m1;

T_max_aus = zeros(size(m1,2),1);
ind_row = zeros(size(m1,2),1);
for k = 1:size(m1,1)
    [T_max_aus(k),ind_row(k)] = max(abs(mdiff(k,:)));
end

[T_max,ind_col] = max(T_max_aus);
zMin = -T_max;
zMax = T_max;

imagesc(mdiff);
caxis([zMin, zMax]);
colormap(cm);
colorbar;
xlabel('[n° pixel]');
ylabel('[n° pixel]');
title('Temperature difference [°C]', 'Interpreter','none');
hold off

%Trova hotspots
punti = zeros(0,3);
[Rows, Columns] = size (mdiff);
[data_x, data_y] = meshgrid( 1:Columns, 1:Rows);
    
figure (2)
%mesh(data_x, data_y, mdiff);
s = surfc(data_x, data_y, mdiff);
%s.EdgeColor = 'none';

hold on

    xlabel('[n° pixel]');
    ylabel('[n° pixel]');
    zlabel('Temperature difference [°C]');
    %Trova massimo
    max_hotspot = find(imregionalmax(mdiff));
    max_hotspot = max_hotspot(mdiff(max_hotspot) >= soglia_max);
    plot3(data_x(max_hotspot),data_y(max_hotspot), mdiff(max_hotspot),'r*','MarkerSize',24);

    %Trova minimo
    min_hotspot = find(imregionalmin(mdiff));
    min_hotspot = min_hotspot(mdiff(min_hotspot) <= soglia_min);
    plot3(data_x(min_hotspot),data_y(min_hotspot), mdiff(min_hotspot),'b*','MarkerSize',24);
    
hold off

%Pulisci workspace
clear S;
   


end

