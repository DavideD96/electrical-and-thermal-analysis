function centre_of_mass()

%Computes BD coefficient, defined as number of significant PC * mean STTC 
%groups = array of strings ["group_x7_y4","group_x2_y6","group_x5_y5","group_x1_y2"]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% sttc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%window = 30;

nframes = 1040;

cd parameters
param = load("ThermalParameters.mat");
end_ = param.ThermalParameters.end_stimulation;
start = param.ThermalParameters.delay;
start = (start - 20);
Rows = param.ThermalParameters.Rows;
Col = param.ThermalParameters.Columns;
cd ..

cd termoFiles_mat
matT = load("mtotalT.mat");
matT = matT.mtotalT;

T_amb = mean(matT(:,:,1),'all');

matT = matT-T_amb;
matT = abs(matT);

X = zeros(end_-start+1,1);
Y = zeros(end_-start+1,1);

for ii=start:end_%start+17:start+19%start:end_
%ii
    M = sum(matT(:,:,ii),'all');
    [x_all,y_all] = meshgrid(linspace(1,Col,Col),linspace(1,Rows,Rows));
    %y_all = meshgrid(linspace(1,Rows,Rows))'

    %x_all enumerates columns
    x_weights = x_all.*matT(:,:,ii);
    y_weights = y_all.*matT(:,:,ii);

    X(ii-start+1) = sum(x_weights,"all")/M;
    Y(ii-start+1) = sum(y_weights,'all')/M;

end

figure
plot(X)
grid on
title('centre of mass X')

hold off

a = figure;
plot(Y)
grid on
title('centre of mass Y')

pause;
[t,~] = ginput(1);
Y = Y(round(t):round(t)+nframes-1);
plot(Y)
grid on

title('centre of mass Y')
ylabel('coordinate')
xlabel('frame')
xlim([0,nframes])

hold off

savefig(a,'centre_of_mass_Y.fig')
save('cm_Y.mat','Y','-mat')

cd ..
end