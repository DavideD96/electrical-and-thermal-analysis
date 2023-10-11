function return_structs = find_regimes(path, max_k, error, e2, plt)
%
% Date: 2019-02-28 Last Modification: 2019-03-21
% Author: Thomas Tiotto (thomas.tiotto@outlook.com)
%
%   find_regimes(path, max_k, {error}, {e2})
%
% Given the path to a file, the script divides the sequence into windows of 
% size "step" and for each one identifies the optimal number of
% regimes (max_k) to cluster the data into.  The technique used is FEM-H1 
% that was first described in "Finite Element Approach to Clustering of 
% Multidimensional Time Series", I. Horenko, 2010.
%
%   'path': the name of the file holding the data
%   'max_k': upper bound in search of optimal regimes, must be >= 3
%   'error': OPTIONAL, the error threshold for the optimisation
%   'e2': OPTIONAL, smoothing parameter for the computed clusters
%   'plt': OPTIONAL, plot or not
% 
% Returns: Struct object containing, for each window the data has been 
%          broken into, the optimal number of centroids,
%          the total error in this classification, affiliation vector
%          Gamma, the centroids and the standard deviation.

    close all;

    if isempty(error)
       error = 1^-1000; 
    end
    if isempty(e2);
       e2 = 10;
    end


    if ischar(path)
        x = load(path);          
    elseif ismatrix(path)
        x = path;       
    end
    
    if max_k<3
        max_k = input('max_k must be larger than 3, insert a new value: ');
    end
        
    return_structs = [];
    step = 200;
    nIntervals = floor(size(x,1) / step); %BUUUUUUUUUUUUUUUUUUUUUHHHHH
    for i = 1 : nIntervals %BUUUUUUUUUUUUUUUUUUUUHHHHHHH
        disp(['****** ', num2str(1 + ((i-1) * step)), ':', num2str(i * step), '****** '])
        distances = [];
        gammas = [];
        centroids = [];
        sigmas = []; %BUUUUUUUUUUUUUUUUUUUUHHHHHHH
        
        init_range = 1 + ((i-1) * step);
        end_range = i * step;
        x_temp = x(init_range : end_range);
        x_temp = x_temp';
        
        total_time = 0;
        if ~isempty(plt)
            figure;
        end
        for k = 1 : max_k
            tic;
            returned = fem_h1(x_temp, k, error, e2);
            total_time = total_time + toc;
            disp(['Running time for K=' , num2str(k), ' is ', num2str(toc), ' seconds'])
            distances = [distances, returned.distance];
            gammas = [gammas, returned.gamma];
            centroids = [centroids; returned.centroids];
            sigmas = [sigmas; returned.sigmas];      %BUUUUUUUUUUUUUHHHHHHH
            
            % plot window showing all regimes and centroids
            if ~isempty(plt)
                % Plot computed clustering with centroids in range [1:max_k]
                sub1 = subplot(max_k,2,k*2-1);
                sub2 = subplot(max_k,2,k*2);

                subplot(sub1);
                plot(x_temp);
                hold on
                x_axis = (1:step);
                scatter(x_axis, x_temp, [], bi2de(returned.gamma), 'filled'); 
                title(['K=', num2str(k), ' Regime affiliation']);

                subplot(sub2);
                hist(x_temp, 30);
                title(['K=', num2str(k), ' Distribution of values']);

                for i=1:k
                    subplot(sub1);
                    colour = rand(1,3);
                    yline(returned.centroids(i), '--r',['\mu ',num2str(i)], 'color', colour);
                    yline(returned.centroids(i) + returned.sigmas(i), ':', 'color', colour);
                    yline(returned.centroids(i) - returned.sigmas(i), ':', 'color', colour);
                    subplot(sub2);
                    xline(returned.centroids(i), '--r',['\mu ',num2str(i)], 'color', colour);
                end

            end
         
        end
        disp(['Total running time ' , num2str(total_time), ' seconds'])

        [val, idx] = max(diff(diff(distances)));
        optimal_k = idx+1;
        disp(['Optimal K: ', num2str(optimal_k)])

    %   Use Gauss' Formula to index the parameters corresponding to the
    %   optimal K that was found
        index = ((optimal_k * (optimal_k - 1))/2);
        optimal_distance = distances(optimal_k);
        optimal_gamma = gammas(:, index + 1 : index + optimal_k);
        optimal_centroids = centroids(index + 1 : index + optimal_k, :);
        optimal_sigmas = sigmas(index + 1 : index + optimal_k,:); %BUUUUUUUUUHHHHHH
        
        if ~isempty(plt)
            sgt = sgtitle({['Window ', num2str(init_range), ':', num2str(end_range)];['Optimal K: ', num2str(optimal_k)]});
            sgt.FontSize = 16;
        end
            
        return_structs = [return_structs, struct('range', [num2str(init_range), ':', num2str(end_range)], 'init_range', init_range,'end_range', end_range, 'optimal_k', optimal_k, 'distance', optimal_distance, 'gamma', optimal_gamma, 'centroids', optimal_centroids, 'sigmas', optimal_sigmas, 'nIntervals', nIntervals)]; %BUUUUUUUUUUHHHHH
end