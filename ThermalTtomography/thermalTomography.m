function thermalTomography(varargin)

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

num = length(varargin);

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

%apro le cartelle e carico i dati
cd(ab_fname)
res_ab = load('Data.mat');
res_ab = mean(res_ab(transiente:end,4));

cd ..
cd(bc_fname)
res_bc = load('Data.mat');
res_bc = mean(res_bc(transiente:end,4));

cd ..
cd(ca_fname)
res_ca = load('Data.mat');
res_ca = mean(res_ca(transiente:end,4));

cd ..
[R1,R2,R3] = FindGrooveResistances(res_ab,res_bc,res_ca);

%conductances
G1 = 1/R1;
G2 = 1/R2;
G3 = 1/R3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% tomography %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Q = rho*j^2 = (express rho in terms of R) = (R*A/L)*j^2 =
%   = (V*A/I*L)*j^2 = (V/L)*j
% where V is the bias, L is the "wideness" of the groove (roughly
% constant), j is the current density.
% P/A = Q*L = V*j = V*I/A = V^2/(R*A) = V^2*G/A = V^2*G/(t*w) prop to T
% P/A is known
% V is known (roughly)  => G/t
% w is known
%
% G = cost*sum(T_i*w_i)
%
%                     partition function
%                              |                               
%                              V
% G_i = cost*T_i*w_i = [G/sum(T_i*w_i)]*T_i*w_i
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Groove1_nonCond = [];
Groove1_cond = []; %matrix

if size(Groove1,2) > size(Groove1,1)
    Groove1_cond = Groove1_cond';
    Groove1_nonCond = Groove1_nonCond';
end

Groove1 = Groove1_cond - Groove1_nonCond;

axis1 = round(size(Groove1,2)/2);

partitionFunction = sum(Groove1(:,axis1));

G1_i = (G1/partitionFunction)*IFOV*Groove1(axis,i)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end