function set_parameters(delay, varargin)

% set parameters for thermal detection
%
% default:
%
% soglia_max = 0.5;
% soglia_min = -0.5;
% samplfr = 30;
% fr_diff = 3;
% detectMeth = 'ThreshNN';
% delay = 0;
%

num = length(varargin);

soglia_max = 0.5;
soglia_min = -0.5;
samplfr = 30;
fr_diff = 3;
detectMeth = 'ThreshNN';

cd termoFiles_mat
    m = load('mtotalT.mat');
    m = m.mtotalT;
cd ..

rows = size(m,1);
col = size(m,2);

for k = 1:2:num
    if prod(varargin{k}=='threshold+')
        soglia_max = varargin{k+1}; %1 = smooth, 0 = grezzo
    elseif prod(varargin{k}=='threshold-')
        soglia_min = varargin{k+1};
    elseif prod(varargin{k}=='sampl_freq')
        samplfr = varargin{k+1}; % 1 = video
    elseif prod(varargin{k}=='frame_diff')
        fr_diff = varargin{k+1}; % 1 = video
    elseif prod(varargin{k}=='detect_met')
        detectMeth = varargin{k+1}; % 1 = trova i centri di massa dei frame con evento
    end
end

ThermalParameters.soglia_max = soglia_max;
ThermalParameters.soglia_min = soglia_min;
ThermalParameters.samplfr = samplfr;
ThermalParameters.fr_diff = fr_diff;
ThermalParameters.detectMeth = detectMeth;
ThermalParameters.Rows = rows;
ThermalParameters.Columns = col;
ThermalParameters.delay = delay;

check = isfolder('parameters');

if check == 0
    mkdir parameters
end

cd parameters
    save("ThermalParameters.mat","ThermalParameters")
cd ..

end