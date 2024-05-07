function thermalTomography(varargin)

% READ CAREFULLY BEEFOR USING THIS FUNCTION
%
% thermal tomography instructions
%
% %%%%%%%%%%%%%%%%%%%%%%% locate CAF and grooves %%%%%%%%%%%%%%%%%%%%%%%%%%
% 0) Data.mat containing electric data must be in each folder.
%
% 1) setInitialRefPoint in reference folder.
%
% 2) setAndCheck in every folder (except reference).
%    (store_mtotalT in every folder.)
%    (findRiseFall in every folder.
%       (it runs also mean_ColdAndHot automatically))
%    you can run checkGrooves to see if you have located the grooves
%    correctly.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now you have all the information to perform tomography.
%
% 3) thermalTomography: NOW YOU CAN RUN THIS FUNCTION
% 4) compareConduction
%
% varargin:
%
%   'cpl_ab': folder where data relative to ab couple reading.
%   'cpl_bc': folder where data relative to bc couple reading.
%   'cpl_ca': folder where data relative to ca couple reading.
%   '_IFOV_': camera(+lens) IFOV.
%   'ax_mea': use only groove axis (1), all pixel perpendicular to groove
%             axis (0) or specify the number (not implemented yet).
%   'N_step': reading step (e.g. folders f42, f43, f44 are associated with
%             the first reding step). the functtion creates a folder with
%             the same name as reading step in order to store tomography 
%             results. 
%
% Thermal image
%   -/8   .   3/7
%    .    |    .
%  .  °   |   °  .      i<=5 = low voltage
% .       |_______.     j>5  = high voltage
% .       |       .
%  .      |      .
%    .    |   °.
%         .   2/6
%
%   2/6 = a     
%   3/7 = b
%   -/8 = c
%
% Topology
%           c
%     Rca   °   Rbc
%        \     /
%         \   /
%          \ / 
%           |    
%    a °    |    ° b
%           |
%          Rab
% 
%
% TOMOGRAPHY PRINCIPLES
%
% Q = rho*j^2 = (express rho in terms of R) = (R*A/L)*j^2 =
%   = (V*A/I*L)*j^2 = (V/L)*j
% where V is the bias, L is the "wideness" of the groove (roughly
% constant), j is the current density.
% P/A = Q*L = V*j = V*I/A = V^2/(R*A) = V^2*G/A = V^2*G/(t*w) prop to T
% P/A is known
% V is known (roughly)  => G/t
% w is known
%
% V^2*G/(t*L*w) = const*T = Q (last equality is a rough assumption)
% or, alternatively G = (t*L*w)*Q/V^2, V = const
% => G = cost*sum(T_i*w_i) = G_i (conduction in parallel)
%
%                     partition function
%                              |                               
%                              V
% G_i = cost*T_i*w_i = [G/sum(T_i*w_i)]*T_i*w_i

num = length(varargin);
ax_mea = 0;

%varagin
for k = 1:2:num
    if prod(varargin{k}=='cpl_ab')
        ab_fname = varargin{k+1}; 
    elseif prod(varargin{k}=='cpl_bc')
        bc_fname = varargin{k+1};
    elseif prod(varargin{k}=='cpl_ca')
        ca_fname = varargin{k+1}; 
    elseif prod(varargin{k}=='_IFOV_')
        IFOV = varargin{k+1}; 
    elseif prod(varargin{k}=='ax_mea')
        ax_mea = varargin{k+1}; 
    elseif prod(varargin{k}=='N_step')
        N_step = varargin{k+1}; 
    end

end

check1 = exist(ab_fname,"dir");
check2 = exist(bc_fname,"dir");
check3 = exist(ca_fname,"dir");

if check1 == 0 
    disp('invalid folder cpl_ab')
elseif check2 == 0
    disp('invalid folder cpl_bc')
elseif check3 == 0
    disp('invalid folder cpl_ca')
end

transiente = 20; %20 Hz, transiente = 1 s

%%%%%%%%%%%%%%%%%%% apro le cartelle e carico i dati %%%%%%%%%%%%%%%%%%%%%%

cd(ab_fname)

%%% a-b
%dati elettrici
res_ab = load('Data.mat');
res_ab = mean(res_ab.R(transiente:end,4));

%grooves coordinates
coord_Groove_ab = load(append(ab_fname,'_groove_a-b_3-6_coordinates'));
coord_Groove_ab = coord_Groove_ab.groove1_coordinates;

cd termoFiles_mat\
% dati termici
coldMean1 = load('coldMean.mat');
coldMean1 = coldMean1.coldMean;
hotMean1 = load('hotMean.mat');
hotMean1 = hotMean1.hotMean;
Groove1 = hotMean1 - coldMean1;
Groove1_ = Groove1(coord_Groove_ab(2,2):coord_Groove_ab(3,2),coord_Groove_ab(1,1):coord_Groove_ab(2,1));

if size(Groove1_,2) > size(Groove1_,1)
    Groove1_ = Groove1_';
end

cd ..
cd ..

cd(bc_fname)

%%% b-c
%dati elettrici
res_bc = load('Data.mat');
res_bc = mean(res_bc.R(transiente:end,4));

%grooves coordinates
coord_Groove_bc = load(append(bc_fname,'_groove_b-c_3-8_coordinates'));
coord_Groove_bc = coord_Groove_bc.groove2_coordinates;

cd termoFiles_mat\
coldMean2 = load('coldMean.mat');
coldMean2 = coldMean2.coldMean;
hotMean2 = load('hotMean.mat');
hotMean2 = hotMean2.hotMean;
Groove2 = hotMean2 - coldMean2;
Groove2_ = Groove2(coord_Groove_bc(2,2):coord_Groove_bc(3,2),coord_Groove_bc(1,1):coord_Groove_bc(2,1));

if size(Groove2_,2) > size(Groove2_,1)
    Groove2_ = Groove2_';
end

cd ..
cd ..

cd(ca_fname)

%%% c-a
%dati elettrici
res_ca = load('Data.mat');
res_ca = mean(res_ca.R(transiente:end,4));

%grooves coordinates
coord_Groove_ca = load(append(ca_fname,'_groove_c-a_2-8_coordinates'));
coord_Groove_ca = coord_Groove_ca.groove3_coordinates;

cd termoFiles_mat\
coldMean3 = load('coldMean.mat');
coldMean3 = coldMean3.coldMean;
hotMean3 = load('hotMean.mat');
hotMean3 = hotMean3.hotMean;
Groove3 = hotMean3 - coldMean3;
Groove3_ = Groove3(coord_Groove_ca(2,2):coord_Groove_ca(3,2),coord_Groove_ca(1,1):coord_Groove_ca(2,1));

if size(Groove3_,2) > size(Groove3_,1)
    Groove3_ = Groove3_';
end

cd ..
cd ..

check = exist('Tomography results', 'dir');
if check == 0
    mkdir('Tomography results')
end

cd('Tomography results')
check = exist(num2str(N_step),'dir');
if check == 0
    mkdir(num2str(N_step))
    cd(num2str(N_step))
else
    answer = inputdlg('Do you want to overwrite the existing folder (1)?');
    if answer{1} == '1'
        cd(num2str(N_step))
    else
        disp('Your results have not been saved.')
    end
end

for j = 1:size(ax_mea,2)

    if ax_mea(1,j) == 0 %all
        Groove1 = mean(Groove1_,2);
    elseif ax_mea(1,j) == 1 %only axis
        axis1 = round(size(Groove1_,2)/2);
        Groove1 = Groove1_(:,axis1);
    end
    
    if ax_mea(1,j) == 0 %all
        Groove2 = mean(Groove2_,2);
    elseif ax_mea(1,j) == 1 %only axis
        axis2 = round(size(Groove2_,2)/2);
        Groove2 = Groove2_(:,axis2);
    end
    
    if ax_mea(1,j) == 0 %all
        Groove3 = mean(Groove3_,2);
    elseif ax_mea(1,j) == 1 %only axis
        axis3 = round(size(Groove3_,2)/2);
        Groove3 = Groove3_(:,axis3);
    end

    %%%%%%%%%%%%%%%%%%%% find global groove resistances %%%%%%%%%%%%%%%%%%%%%%%
    
    [R1,R2,R3] = FindGrooveResistances(res_ab,res_bc,res_ca);
    
    %conductances
    G1 = 1/R1;
    G2 = 1/R2;
    G3 = 1/R3;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% tomography %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % now I have a 1D array 
    
    partitionFunction1 = sum(Groove1)*IFOV;
    G_Groove1 = (G1/partitionFunction1)*IFOV*Groove1; %G_i = [G/sum(T_i*w_i)]*T_i*w_i
    
    partitionFunction2 = sum(Groove2)*IFOV;
    G_Groove2 = (G2/partitionFunction2)*IFOV*Groove2; %G_i = [G/sum(T_i*w_i)]*T_i*w_i
    
    partitionFunction3 = sum(Groove3)*IFOV;
    G_Groove3 = (G3/partitionFunction3)*IFOV*Groove3; %G_i = [G/sum(T_i*w_i)]*T_i*w_i

    figure
    subplot(2,1,1)
    plot(Groove1)
    grid on
    title('temperature along groove1')

    subplot(2,1,2)
    plot(G_Groove1)
    grid on
    title('conductivity along groove1')

    hold off
    %sum(G_Groove1(:))
    
    figure
    subplot(2,1,1)
    plot(Groove2)
    grid on
    title('temperature along groove2')

    subplot(2,1,2)
    plot(G_Groove2)
    grid on
    title('conductivity along groove2')

    hold off
    %sum(G_Groove2(:))
    
    figure
    subplot(2,1,1)
    plot(Groove3)
    grid on
    title('temperature along groove3')

    subplot(2,1,2)
    plot(G_Groove3)
    grid on
    title('conductivity along groove3')

    hold off 
    %sum(G_Groove3(:))
    if ax_mea(1,j) == 0
        analysis_type = '_mean';
    elseif ax_mea(1,j) == 1 
        analysis_type = '_axis';
    end

    save(append(ab_fname,analysis_type,'_Tgroove_a-b_3-6.mat'),'Groove1')
    save(append(bc_fname,analysis_type,'_Tgroove_b-c_3-8.mat'),'Groove2')
    save(append(ca_fname,analysis_type,'_Tgroove_c-a_2-8.mat'),'Groove3')
    save(append(ab_fname,analysis_type,'_Ggroove_a-b_3-6.mat'),'G_Groove1')
    save(append(bc_fname,analysis_type,'_Ggroove_b-c_3-8.mat'),'G_Groove2')
    save(append(ca_fname,analysis_type,'_Ggroove_c-a_2-8.mat'),'G_Groove3')
end

cd ..
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end