function plotRS_Keithley2606B(nomefile,volt_or_curr)

%check for directory where saving the data
check = exist('RSResults');
if check ~= 7
    mkdir RSResults;
end
%save the folder path where save data
cd('RSResults');
path = cd;
cd ..;

%go to the folder where there are the data to be analyzed
%cd(folder);


checkFile = exist(nomefile);
if checkFile ~= 2
    disp('File not found.');
    cd ..;
    return
end

data = dlmread(nomefile);
R_ = data(data(:,3) ~= 0,:);
%cd ..;
R_(:,1) = R_(:,1)-R_(1,1);

if volt_or_curr == 0 %volt const
    voltage = R_(:,2);
    I = R_(:,3);
    Resistance = voltage./I;
    R = [R_(:,1), voltage, I, Resistance];

elseif volt_or_curr == 1 %curr const
    voltage = R_(:,3);
    I = R_(:,2);
    Resistance = voltage./I;
    R = [R_(:,1), voltage, I, Resistance];
end

figure;
plot(R(:,1), R(:,end));
title(['entire evolution of the resistance (',num2str(voltage(1,1)),' V)'])
grid on;
xlabel('time [s]'); 
ylabel('resistance [\Omega]');
build_path = [path,'\resistance_',nomefile,'_',num2str(voltage(1,1)),'V.fig'];
savefig(build_path);

figure;
plot(R(:,1), R(:,end-1));
title(['entire evolution of the current (',num2str(voltage(1,1)),' V)'])
grid on;
xlabel('time [s]'); 
ylabel('current [A]');

figure;
plot(R(:,1), R(:,2));
title(['entire evolution of the voltage (',num2str(voltage(1,1)),' V)'])
grid on;
xlabel('time [s]'); 
ylabel('voltage [V]');

save('Data.mat','R');
end