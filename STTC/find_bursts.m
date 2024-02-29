function burst_serie = find_bursts(serie)

isi = ISIpuntiSimili(serie, 'full');
m_isi = mean(isi);
L = isi(isi<m_isi);

m_l = mean(L);

ind_ev = find(serie,sum(serie(:,2)));
burst_serie = zeros(size(serie,1),2);
burst_serie(:,1) = serie(:,1);
burst_isi = zeros(size(isi,1),2);

ind = 1;
ultimo_cambio = 1;

for i=1:size(isi,1)

    if mean(isi(ultimo_cambio:i)) > m_l
        disp(mean(isi(ultimo_cambio:i-1)))
        ultimo_cambio = i;
        ind = ind+1;
    end

    burst_serie(ind_ev(i),2) = ind;
    burst_isi(i,1) = isi(i);
    burst_isi(i,2) = ind;
end

disp('numero bursts')
ind
end