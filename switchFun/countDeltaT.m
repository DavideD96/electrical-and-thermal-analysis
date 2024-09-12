function cnt = countDeltaT(dati, deltaT)

%Last Modification: 2019-06-26 
%   cnt = countDeltaT(dati,deltaT)
%
%It counts the number of switch in each time bin 
%
%   dati: matrix with only switch events
%   deltaT: time interval width for the analysis

check = 1;

k=1;
j=1;
cnt(j,1)=1;
while k <= size(dati,1)
    i=1;
    n=1;
          %condition k+i <= size(dati) before condition on deltaT
          %so the correct dimension is accounted for
    while k+i <= size(dati,1) & dati(k+i,1)-dati(k,1)<deltaT  
        n=n+1;
        i=i+1;
    end
    cnt(j,1) = n;
    k = k + i;
    j = j + 1;
end

end