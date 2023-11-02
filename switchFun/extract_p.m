function [sv,li,ui] = extract_p (x,lb,ub)

%   [v,li,ui] = extract_p (x,lb,ub)
%Extract the subvector sv of the x  vector elemnts between a lower limit 
%an upper one. 
%
%   x: initial vector   
%   lb: lower bound interva limit
%   up: upper bound inteval limit
%   v = extarcted subvector
%   li: index of the the vector x fro the lower limit
%   ui: index of the the vector x fro the upper limit


idx = x>=lb & x<=ub;
ind = find(idx);


li = ind(1);
ui = ind(end);
sv = x(li:ui);

end