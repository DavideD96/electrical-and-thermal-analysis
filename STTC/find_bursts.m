function [burst_serie,burst_isi,mean_isi_in_burst] = find_bursts(serie)

% Unsupervised learing algorithm to find bursts.
% See: L. Chen, Y. Deng, W. Luo, Z. Wang, e S. Zeng, «Detection of bursts in 
% neuronal spike trains by the mean inter-spike interval method», Prog. Nat. Sci., 2009.

isi = ISIpuntiSimili_old(serie, 'full');
m_isi = mean(isi);
L = isi(isi<m_isi);

m_l = mean(L);

ind_ev = find(serie(:,2));
burst_serie = zeros(size(serie,1),2);
burst_serie(:,1) = serie(:,1);
burst_isi = zeros(size(isi,1),2);

ind = 1;
ultimo_cambio = 1;

burst_serie(ind_ev(1),2) = ind;

k = 1;
while k <= size(isi,1)
    
    if mean(isi(ultimo_cambio:k)) > m_l % allora significa che esco dal burst
        ultimo_cambio = k+1;
        ind = ind+1;  
        burst_serie(ind_ev(k+1),2) = ind;
        burst_isi(k,1) = isi(k);
        burst_isi(k,2) = 0;
        k = k+1;
    else
        burst_serie(ind_ev(k+1),2) = ind;
        burst_isi(k,1) = isi(k);
        burst_isi(k,2) = ind;
        k = k+1; 
    end
end

% for i=1:size(isi,1)
%     disp(mean(isi(ultimo_cambio:i)))
%     if mean(isi(ultimo_cambio:i)) > m_l
%         %disp(mean(isi(ultimo_cambio:i-1)))
%         ultimo_cambio = i;
%         ind = ind+1;
% 
%     end
% 
%     burst_serie(ind_ev(i+1),2) = ind;
%     burst_isi(i,1) = isi(i);
%     burst_isi(i,2) = ind;
% end

% disp('numero bursts')
% ind
mean_isi_in_burst = zeros(ind,1);

for k=1:ind
    %burst_isi(burst_isi(:,2)==k)
    mean_isi_in_burst(k) = mean(burst_isi(burst_isi(:,2)==k),1);
end

mean_ = mean(mean_isi_in_burst(~isnan(mean_isi_in_burst)));
std_ = std(mean_isi_in_burst(~isnan(mean_isi_in_burst)));

plot(mean_isi_in_burst, 'o')
grid on
ylabel('mean isi in bursts [s]')
hold on
yline(mean_)
yline(mean_+std_,"LineStyle","--")
yline(mean_-std_,"LineStyle","--")
hold off

figure
iISI = isi(1:end-1);
iplus1ISI = isi(2:end);

scatter(iISI,iplus1ISI);
hold on;
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
yline(m_l);
xline(m_l);
xline(mean_,"LineStyle","--")
yline(mean_,"LineStyle","--")
grid on
xlabel('i^{th} ISI [s]')
ylabel('i+1^{th} ISI [s]')
hold off

end