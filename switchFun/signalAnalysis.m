function sar = signalAnalysis(mat, col, numLags, path, folder)
%Date of creation: 2019-06-30     Last modification: //
%
%   sar = signalAnalysis(mat, col, numLags, path, folder)
%
%   mat: data matrix
%   col: column dato to be analyzed
%   numLags: number of lags for the ompution of the autocc function (see autocorr help)
%   path: path where data are to be saved
%   folder: directory where original data are found
%
%   sar: a 1x5 cell 
%                  {acf, pcf, lbqtest, fft, psd}  
%Note: add the the whole matrix and compute all the needed elemnts(voltage, delay,...)
%

%----set parameters and variables----
    interv = diff(mat(:,1));
    T = mean(interv);       %delay
    
    voltage = mat(1,2);     %voltage
    L=size(mat,1);          %dimension data set
    
    sar = cell(1,5);        %cell results
%----detrending operation on column defined by 'col'----        
    [mat(:,col), degree] = detrend_(mat(:,1),mat(:,col));        
%----build_path-----
    build_path = [path,'\fldr',folder,'_V',num2str(voltage),'_detrendDegree_',num2str(degree)];
%------------------------------------

%f = 10*(0:(L/2))/L; COMMENTATO 07/05/19
f = 0:1/(T*L):(1/(2*T)); %AGGIUNTO 07/05/19


%----autocorrelation function----
[sar{1,1}, lagsAutocorr, boundsAutocorr] = autocorr(mat(:,col),numLags); %for matlab version later 2018 'NumLags',numLags);
figure;
subplot(2,1,1);
plot(lagsAutocorr,sar{:,1}, 'ro'); %[0:numLags]
stem(lagsAutocorr,sar{:,1},'filled','r-o','MarkerSize',4,'Tag','ACF');
grid on;
hold on;
plot(lagsAutocorr,boundsAutocorr(1,1)*ones(size(lagsAutocorr)), '-b');
plot(lagsAutocorr,boundsAutocorr(2,1)*ones(size(lagsAutocorr)), '-b');
title('Autocorrelation function');
xlabel('lag');
ylabel('ACF');
hold off;

%----parcorr function----
[sar{1,2}, lagsParcorr, boundsParcorr] = parcorr(mat(:,col),numLags); %'NumLags',numLags);
subplot(2,1,2);
plot([0:numLags],sar{:,2}, 'ro');
stem([0:numLags],sar{:,2},'filled','r-o','MarkerSize',4,'Tag','ACF');
grid on;
hold on;
plot(lagsParcorr,boundsParcorr(1,1)*ones(size(lagsParcorr)), '-b');
plot(lagsParcorr,boundsParcorr(2,1)*ones(size(lagsParcorr)), '-b');
title('Parcorr');
xlabel('lag');
ylabel('PACF');

%----lbqtest----
sar{1,3} = lbqtest(mat(:,col), 'Lags',1); %non gli passo residuals, ma vectorData, già detrendato
textbox = text(max(lagsParcorr)-4.5,0.8,{'LBQtest: ',num2str(sar{1,3})});
textbox.LineWidth = 0.5;
textbox.EdgeColor = 'k';
textbox.Clipping = 'on';
if sar{1,3} == 1
    textbox.BackgroundColor = 'r'; %c'è autocorrelazione
else
    textbox.BackgroundColor = 'g'; %non c'è autocorrelazione
end
%save autocorrelations graphs
savefig([build_path,'_correlation.fig']);
%----autocorrelation ending----

%----frequency domain analysis----
figure;
subplot(2,1,1);
%----fft----
Fs = 1/T;
f = Fs*(0:(L/2))/L;

fft_ = fft(mat(:,col));
P2 = abs(fft_/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f,P1);
xlabel('frequency [Hz]'); %assumendo segnale campionato ogni 0.1 s
ylabel('weight of the frequency');

sar{1,4} = fft_;
 
fft_ = fft_(1:L/2+1);
psd = (T/L)*abs(fft_).^2;
psd(2:end-1) = 2*psd(2:end-1);
subplot(2,1,2);
plot(f,10*log10(psd));
grid on;

savefig([build_path,'_FFT.fig']);
xlabel('frequency [Hz]');
ylabel('power');

sar{1,5} = [f', psd];

end