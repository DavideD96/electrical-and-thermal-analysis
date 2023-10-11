function returned = fem_h1(x, K, error, e2)
%
% Date: 2019-02-28 Last Modification: 2019-03-21
% Author: Thomas Tiotto (thomas.tiotto@outlook.com)
%
%   fem_h1(x, K, error, e2)
%
% Given a 1D vector of data the script calculates the optimal affiliation
% vector Gamma and the relative K centroids.
% The technique used is FEM-H1 that was first described in
% "Finite Element Approach to Clustering of Multidimensional Time Series", I. Horenko, 2010.
% 
% Note that the asymptotic complexity is linear in the observation dimension 
% and time series length, quadratic in the number of clusters and polynomial 
% in the number N of finite elements (scales approx. O( N^2 log N)
% It should be mentioned that the standard QP-solver from MATLAB was applied 
% in the current realizations of the code. The sparsity structure of the QP 
% subproblem allows to use sparse QP (SQP) solvers available on the market. 
% This will reduce the numerical cost of the method to O( N log N ).
%
%   'path': the name of the file holding the data
%   'K': the number of regimes to compute for
%   'error': OPTIONAL, the error threshold for the optimisation
%   'e2': OPTIONAL, smoothing parameter for the computed clusters
% 
% Returns: Struct object containing the total error in this classification,
%          affiliation vector Gamma, the K centroids and the standard deviation.
    
    if isempty(error)
       error = 1^-1000; 
    end
    if isempty(e2);
       e2 = 10;
    end
    
    T = size(x,2);
    dims = size(x,1);

    % set initial feasible Gamma_0 
    Gamma = rand(K*T,1);
    gamma_sum = zeros(T,1);
    for k=1:K
        gamma_sum = gamma_sum + get_gamma(Gamma,k,T);
    end
    for k=1:K
        Gamma((k-1)*T+1:k*T) = get_gamma(Gamma,k,T) ./ gamma_sum;
    end

    % initialise random centroids
    theta = randn(K, dims);
    sigma = zeros(K,dims);  % BUUUUUUUUUUHHHH

    % compute Hessian
    tmp = [ones(T-1,1),-ones(T-1,1)];
    D = spdiags(tmp,[0,1],T-1,T);
    H_small = full(D'*D);
    Ar = repmat(H_small, 1, K); 
    Ac = mat2cell(Ar, size(H_small,1), repmat(size(H_small,2),1,K));    
    H = blkdiag(Ac{:});
    H = e2*H;

    % lower and upper bounds
    lb = zeros(T*K,1);
    ub = ones(T*K,1);

    B = eye(T);
    tmp = eye(T);
    for k = 1:K-1
        B = horzcat(B,tmp);
    end
    c = ones(T,1);

    % iterations
    err = Inf;

    while err > error

        % compute function g(t)=(x(t) - theta)
        g = zeros(K*T,1);
        for k = 1:K
            g((k-1)*T+1:k*T) = abs(x - theta(k)).^2; % abs instead of euclidean norm as we are working with scalars 
        end

        % err = calculate error between new and old function
        func_old = 0;
        for k = 1:K
            % dot(Gamma(),g()) + H1
            func_old = func_old + dot(get_gamma(Gamma,k,T), get_g(g,k,T));
            func_old = func_old + e2 * get_gamma(Gamma,k,T)' * H_small * get_gamma(Gamma,k,T); 
        end

        % compute Gamma
        % pass 2*H because quadprog expects 1/2*H
        options =  optimset('Display','off');
        Gamma = quadprog(2*H,g,[],[],B,c,lb,ub,[],options);

        % compute Theta
        for k = 1:K
            if sum(Gamma((k-1)*T+1:k*T)) ~= 0
                theta(k) = dot(get_gamma(Gamma,k,T),x) / sum(get_gamma(Gamma,k,T));
            else
                theta(k) = 0;
            end
        end

        % err = calculate error between new and old function
        func_new = 0;
        for k = 1:K
            % dot(Gamma(),g()) + H1
            func_new = func_new + dot(get_gamma(Gamma,k,T),get_g(g,k,T));
            func_new = func_new + e2 * get_gamma(Gamma,k,T)' * H_small * get_gamma(Gamma,k,T); % missing multiplication with e2
        end

        err = abs(func_new - func_old);

    end

    % % plot new affiliation vector
    Gamma = reshape(Gamma, [T,K]);
    Gamma_rounded = round(Gamma);
    Gamma_colours = bi2de(Gamma_rounded);
    % compute Sigma
    for k = 1:K
        %sigma(k)= std(x(logical(Gamma_rounded(:,k))));            %BUUUUUUUUUUUUUUUUUHHHHHHH
            if sum(Gamma_rounded(:,k)) ~= 0
                sigma(k)= std(x(logical(Gamma_rounded(:,k))))
            else
                sigma(k) = 0;
            end

    end

    returned.distance = sum(dot(Gamma_rounded,pdist2(x',theta)));
    returned.gamma = Gamma_rounded;
    returned.centroids = theta;
    returned.sigmas = sigma;
end


function gammakt = get_gamma(Gamma,k,T)
    gammakt = Gamma((k-1)*T+1:k*T);
end

function gkt = get_g(g,k,T)
    gkt = g((k-1)*T+1:k*T);
end

