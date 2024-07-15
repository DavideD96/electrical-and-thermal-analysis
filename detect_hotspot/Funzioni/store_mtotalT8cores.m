function store_mtotalT8cores(filename, fr_end, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-15 Last modification: 2024-04-12
%Author: Cristina Zuccali
%store_mtotalT(filename, fr_end,fr_diff, coordname)
%
%Return the matrix of frames
%
%   'filename' = principal part of the file name of frame (without number
%        of frame and .CSV: for example 'Example_1V_2mm_(frame).CSV' must
%        be indicated as 'Example_1V_2mm_'.                 
%   'fr_end' = number of end frame
%   'coordname' = name of file with coordinates of the wanted region
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Flir = 1;

    ncores = feature('numcores');

    % Verifica se il Parallel Computing Toolbox è disponibile
    if ~license('test', 'Distrib_Computing_Toolbox')
        error('Il Parallel Computing Toolbox non è disponibile.');
    end

    % Avvia un pool di worker per il parallel computing
    pool = gcp('nocreate'); % Verifica se esiste già un pool
    if isempty(pool)
        pool = parpool('local', ncores); % Avvia un nuovo pool con 8 core
    end

    num = length(varargin);

    if num > 0
        coordname = varargin{1};
    end

    load(append(filename,'CAF_coordinates.mat'))
    check = exist(append(filename,'CAF_coordinates.mat'),"file");
    if check ~= 0
        coordname = append(filename,'CAF_coordinates.mat');
    end

    coordname
    m = get_data002(filename, 1, coordname, Flir);
    [Rows, Columns] = size(m);
    mtotalT = zeros(Rows,Columns,fr_end);

    mtotalT(:,:,1) = m;
    
    parfor i = 2:fr_end
        %waitbar(i/fr_end)
        mtotalT(:, :, i) = get_data002(filename, i, coordname, Flir);        
    end

    % Opzionale: chiudi il pool di worker al termine del lavoro
    delete(gcp('nocreate'));

    %salvo matrice
    check = isfolder('termoFiles_mat');
    if check == 0
        mkdir termoFiles_mat;
    end
    cd termoFiles_mat 
    save("mtotalT.mat", "mtotalT");
    cd ..    

    disp('Finito mtotalT')
end

