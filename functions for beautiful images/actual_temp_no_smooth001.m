function actual_temp_no_smooth001(groupedOrNot,varargin)

num = length(varargin);
Rext = 0;
Text = 0;
smooth = 0;
useParam = 0;
startEnd = [0,300];

%varagin
for k = 1:2:num
    if prod(varargin{k}=='startEnd')
        startEnd = varargin{k+1}; %1 = smooth, 0 = grezzo
    elseif prod(varargin{k}=='useParam')
        useParam = varargin{k+1}; %1 = smooth, 0 = grezzo
    elseif prod(varargin{k}=='_smooth_')
        smooth = varargin{k+1}; %1 = smooth, 0 = grezzo
    elseif prod(varargin{k}=='Textrema')
        Text = varargin{k+1}; %1 = smooth, 0 = grezzo
    elseif prod(varargin{k}=='Rextrema')
        Rext = varargin{k+1}; %1 = smooth, 0 = grezzo
    end
end

if groupedOrNot == 0
    cd termoFiles_mat\
    dat = load("DD_Eventi_Termo.mat");
    dat = dat.DD_Eventi;
    cd ..
else
end

cd parameters 
    param = load("ThermalParameters.mat");
    param = param.ThermalParameters;
    startFr = param.delay;
    diff = param.fr_diff;
cd ..

cd termoFiles_mat\
    mDT = load('mtotalDT.mat');
    mDT = mDT.mtotalDT;
cd ..

mDT = mDT(:,:,(startFr-diff):end);

if smooth == 1
    for ii = 1:size(mDT,3)
        [C, S] = wavedec2(mDT(:,:,ii), 1, 'db4');
        %ricostruzione immagine
        mDT(:,:,ii) = wrcoef2("a",C,S,'db4',1);
    end
end

Rows = size(mDT,1);
Columns = size(mDT,2);
[data_x, data_y] = meshgrid(1:Columns, 1:Rows);
t = zeros(size(dat,1),1);
temp_vs_t = zeros(size(dat,1),1);

for ii = 1:size(dat,1)
    t(ii) = dat{ii,1};
    evts = dat{ii,2};
    temp = [];
    for kk = 1:size(evts,1)    
        if evts(kk,1) ~= 0
            %evts
            coordx = data_x(evts(kk,1));
            coordy = data_y(evts(kk,1));
            temp = [temp,mDT(coordy,coordx,ii)];
        end
    end

    if size(temp) ~= 0
        neg = temp(temp < 0);
        pos = temp(temp > 0);
        %temp
        [~, ind] = max(abs(temp));
        temp_vs_t(ii) = temp(ind);
    end
end

rs = mainSwitch('Data.mat','parameters','sig','nos',6,'RoG',1,'col',3,'nvt',useParam);
rs = rs.detection;
%a = figure;

subplot(2,1,1)
plot(rs(:,1)-rs(1,1),rs(:,end),'LineWidth',1,'Color','r')
%xlabel('time [s]')
%set(gca,'xTick',[])
xticklabels({})
ylabel('\Delta conductance [\Omega^{-1}]')
xlim(startEnd)
set(gca,'FontSize',14)
if Rext == 0
    extr = 10000*max(abs(rs(:,end)));
    ylim([-ceil(extr)/10000,ceil(extr)/10000]);
    ticks = round(linspace(0,ceil(extr),4))./10000;
    ticks = [flip(-1.*ticks(2:end)),0,ticks(2:end)]; %round(linspace(0,extr,4))]
    yticks(ticks)
else
    ylim([-Rext,Rext])
    ticks = (linspace(0,ceil((Rext)*10000),4))./10000;
    ticks = [flip(-1.*ticks(2:end)),0,ticks(2:end)]; %round(linspace(0,extr,4))]
    yticks(ticks)
end

grid on

subplot(2,1,2)
plot(t-t(1),temp_vs_t,'LineWidth',1)
xlabel('time [s]')
ylabel('\Delta Temperature [K]')
xlim(startEnd)
set(gca,'FontSize',14)

if Text == 0
    extr = max(abs(temp_vs_t));
    ylim([-ceil(extr),ceil(extr)]);
    ticks = round(linspace(0,ceil(extr),4));
    ticks = [flip(-1.*ticks(2:end)),0,ticks(2:end)]; %round(linspace(0,extr,4))]
    yticks(ticks)
else
    ylim([-Text,Text])
    ticks = (linspace(0,ceil(Text+1),4));
    ticks = [flip(-1.*ticks(2:end)),0,ticks(2:end)]; %round(linspace(0,extr,4))]
    yticks(ticks)
end

%yticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'})
grid on

figure
histogram(rs(rs(:,end)~=0,end),'EdgeColor','k','FaceColor','r')
xlabel('\DeltaConductance [\Omega^{-1}]')
ylabel('counts')
grid on
figure
histo_termal001()
ylabel('counts')
xlabel('\DeltaTemperature [K]')
grid on

end