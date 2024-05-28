function sttc = STTCmultiple_windows(series1,series2,deltat_int,npoints)

deltat = linspace(deltat_int(1),deltat_int(2),npoints);
sttc = zeros(npoints,2);
for i = 1:npoints
    sttc(i,1) = deltat(i);
    sttc(i,2) = STTC_001(series1,series2,deltat(i));
end

newStr1 = erase(series1,'.mat');
newStr2 = erase(series2,'.mat');

a = figure;
plot(sttc(:,1),sttc(:,2))
title(append(newStr1,'_VS_',newStr2));
xlabel('\Deltat [s]');
ylabel('STTC [adim.]');
grid on

savefig(append(newStr1,'_VS_',newStr2));
saveas(a,append(newStr1,'_VS_',newStr2,'.png'),'png');

end