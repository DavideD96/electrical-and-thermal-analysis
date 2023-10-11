function autocorr_parcorr_test = autocorrelations(vectorData, numLags, path, folder, voltage, degree, delay)
%Date of creation: unkown     Last modification: 2019-06-26
%
%   autocorr_parr = autocorrelations(vectorData, numLags, path, folder, voltage, degree, delay)
%
%   vectorData: a column vector fo the time series data
%   numLags: number of lags for the computation of the autocc function (see autocorr help)
%   path: path where data are to be saved
%   folder: directory where original data are found
%   volage: voltage bias  
%   degree: degree of the detrendng polynomial func
%   delay: sampling time
%
%   autocorr_parr: a 1x5 cell 
%                  {acf, pcf, lbqtest, fft, psd}  
%Note: add the the whole matrix and compute all the needed elemnts(voltage, delay,...)
%


L=size(vectorData,1)
T = delay;
Fs = 1/T;
%f = 10*(0:(L/2))/L; COMMENTATO 07/05/19
f = 0:1/(T*L):(1/(2*T)); %AGGIUNTO 07/05/19
autocorr_parcorr_test = cell(1,5);

[autocorr_parcorr_test{1,1}, lagsAutocorr, boundsAutocorr] = autocorr(vectorData,numLags); %'NumLags',numLags);
[autocorr_parcorr_test{1,2}, lagsParcorr, boundsParcorr] = parcorr(vectorData,numLags); %'NumLags',numLags);

figure;
subplot(2,1,1);
plot(lagsAutocorr,autocorr_parcorr_test{:,1}, 'ro'); %[0:numLags]
stem(lagsAutocorr,autocorr_parcorr_test{:,1},'filled','r-o','MarkerSize',4,'Tag','ACF');
grid on;
hold on;
plot(lagsAutocorr,boundsAutocorr(1,1)*ones(size(lagsAutocorr)), '-b');
plot(lagsAutocorr,boundsAutocorr(2,1)*ones(size(lagsAutocorr)), '-b');
title('Autocorrelazione.');
xlabel('lag');
ylabel('Autocorrelazione');
hold off;

subplot(2,1,2);
plot([0:numLags],autocorr_parcorr_test{:,2}, 'ro');
stem([0:numLags],autocorr_parcorr_test{:,2},'filled','r-o','MarkerSize',4,'Tag','ACF');
grid on;
hold on;
plot(lagsParcorr,boundsParcorr(1,1)*ones(size(lagsParcorr)), '-b');
plot(lagsParcorr,boundsParcorr(2,1)*ones(size(lagsParcorr)), '-b');
title('Autocorrelazione parziale.');
xlabel('lag');
ylabel('Autocorrelazione parziale'); 

%mean_R = mean(vectorData(:,1)); %tolti
%residuals = vectorData(:,1) - mean_R; %tolti
autocorr_parcorr_test{1,3} = lbqtest(vectorData, 'Lags',1); %non gli passo residuals, ma vectorData, già detrendato

%mTextBox = uicontrol('style','text');
%set(mTextBox,'String',{'LBQtest: ',num2str(autocorr_parcorr_test{1,3})});
textbox = text(max(lagsParcorr)-4.5,0.8,{'LBQtest: ',num2str(autocorr_parcorr_test{1,3})});
textbox.LineWidth = 0.5;
textbox.EdgeColor = 'k';
textbox.Clipping = 'on';

if autocorr_parcorr_test{1,3} == 1
    textbox.BackgroundColor = 'r'; %c'è autocorrelazione
else
    textbox.BackgroundColor = 'g'; %non c'è autocorrelazione
end

build_path = [path,'/AUTOCORR_',folder,'_V',num2str(voltage),'_detrendDegree_',num2str(degree),'.fig'];
savefig(build_path);

%-------------Fourier Transform-------------
isOdd = mod(L,2)==0 %true se è pari 
if isOdd == 1
    %f = 0:1/(T*L):(1/(2*T)); %AGGIUNTO 27/06/19
    figure;
    subplot(2,1,1);
    %vectorDataNor = normalize(vectorData, 'range'); %così normalizzo i dati
    fft_ = fft(vectorData);
    P2 = abs(fft_/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    plot(f,P1);
    xlabel('frequency [Hz]'); %assumendo segnale campionato ogni 0.1 s
    ylabel('weight of the frequency');

    autocorr_parcorr_test{1,4} = fft_;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%% PSD %%%%%%%%%%%%%%%%new
    fft_ = fft_(1:L/2+1);
    psd = (T/L)*abs(fft_).^2;
    psd(2:end-1) = 2*psd(2:end-1);
    subplot(2,1,2);
    plot(f,10*log10(psd));
    grid on;
    
else
    f = f(1:end-1);
    %%%%% FAST FOURIER TRANSFORM %%%%%
    figure;
    subplot(2,1,1);
    %vectorDataNor = normalize(vectorData, 'range'); %così normalizzo i dati
    fft_ = fft(vectorData);
    size(fft_)
    %disp(size(f));
    %disp(size(fft_));
    P2 = abs(fft_/L);
    P1 = P2(1:(L-1)/2);
    P1(2:end-1) = 2*P1(2:end-1);
    plot(f,P1);
    xlabel('frequency [Hz]'); %assumendo segnale campionato ogni 0.1 s
    ylabel('weight of the frequency');

    autocorr_parcorr_test{1,4} = fft_;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%% PSD %%%%%%%%%%%%%%%%new
    fft_ = fft_(1:L/2);
    psd = (T/L)*abs(fft_).^2;
    psd(2:end-1) = 2*psd(2:end-1);
    subplot(2,1,2);
    plot(f,10*log10(psd));
    grid on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%-------------------------------------------
build_path = [path,'/PSD_',folder,'_V',num2str(voltage),'_detrendDegree_',num2str(degree),'.fig'];
savefig(build_path);
xlabel('frequency [Hz]');
ylabel('power');

autocorr_parcorr_test{1,5} = [f', psd];


end