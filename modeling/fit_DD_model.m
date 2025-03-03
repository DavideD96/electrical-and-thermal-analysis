function fit_DD_model()


%data = [V,Cold,Cnew];

data = [1, 0.001, 0.002;2, 0.001, 0.002;4, 0.001, 0.0015;1, 0.001, 0.002;...
    1, 0.001, 0.002;2, 0.001, 0.003;1, 0.001, 0.002;1, 0.001, 0.002;];

%surfit = @(B,XY)  XY(:,1)-(-4*self.max_prob_set/(self.min_setV-self.max_setV)**2)*(V-(self.min_setV+self.max_setV)/2)**2+self.max_prob_set; 

data = [1, 0; 1.5, 0; 2, 0.1; 2.5, 0.2; 3, 0.15; 3.5, 0.05; 4, 0; 4.5, 0.01];

myFun = @(p, XY) (XY(:,1) < p(1)) .* 0 + ... 
                 all([(XY(:,1) >= p(1)), (XY(:,1) <= p(2))]) .* (3/(2*(p(2)-p(1))))*((((-4/(p(1)-p(2))^2))*XY(:,1)-(p(1)+p(2))/2).^2+1); %p(1) Vmin, p(2) Vmax, p(3) prob set max

%test su dati casuali
p_true = [2, 4];
X = rand(200,1) * 5 - 1; % Da -1 a 4

%3/(2*(p_true(2)-p_true(1)))
%size((3/(2*(p_true(2)-p_true(1))))*((((-4/(p_true(1)-p_true(2))^2))*X-(p_true(1)+p_true(2))/2).^2+1))
%size((X(:,1) >= p_true(1)) .* (3/(2*(p_true(2)-p_true(1)))).*((((-4/(p_true(1)-p_true(2))^2))*X-(p_true(1)+p_true(2))/2).^2+1))
%size((X(:,1) < p_true(1)) .* 0)

Z = (X(:,1) < p_true(1)) .* 0 + ... 
    all([(X(:,1) >= p_true(1)), (X(:,1) <= p_true(2))]) .* (3/(2*(p_true(2)-p_true(1)))).*((((-4/(p_true(1)-p_true(2))^2))*X(:,1)-(p_true(1)+p_true(2))/2).^2+1); %p(1) Vmin, p(2) Vmax, p(3) prob set max

%plot(X,Z)

%XY = [X, Y]; % Raggruppiamo i dati
p0 = [2.2, 2.5]; % Valori iniziali dei parametri

pOpt = lsqcurvefit(myFun, p0, X, Z);
disp(pOpt);
end