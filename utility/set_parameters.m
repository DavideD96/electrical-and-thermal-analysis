function set_parameters(varargin)

num = length(varargin);

for k = 1:2:num
    if prod(varargin{k}=='threshold+')
        soglia_max = varargin{k+1}; %1 = smooth, 0 = grezzo
    elseif prod(varargin{k}=='threshold-')
        soglia_min = varargin{k+1};
    elseif prod(varargin{k}=='sampl_freq')
        sampfr = varargin{k+1}; % 1 = video
    elseif prod(varargin{k}=='frame_diff')
        fr_diff = varargin{k+1}; % 1 = video
    elseif prod(varargin{k}=='detect_met')
        detectMeth = varargin{k+1}; % 1 = trova i centri di massa dei frame con evento
    end
end

ThermalParameters.soglia_max = soglia_max;
ThermalParameters.soglia_min = soglia_min;
ThermalParameters.samplfr = sampfr;
ThermalParameters.soglia_max = soglia_max;
ThermalParameters.soglia_max = soglia_max;

end