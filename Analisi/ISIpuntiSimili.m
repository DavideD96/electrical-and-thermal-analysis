function int = ISIpuntiSimili(analyzed,method)

%Date: 2019-02-18 Last Modification: --
%Author: M. Camponovo, D. Decastri, M. Mirigliano
%           int = ISI(analyzed,method)
%The program anlyzed the last column of matrix 'analyzed' and collects the
%time distance between two switch.
%           
%   analyzed = (times,switchfound)
%   method: if method = full all consecutive switch interval are computed 
%           if method = half only couples of switches interval are computed
%
%   int = matrix that contain the time distance beetwen two switch

if prod(method == 'full')

    s = size(analyzed(:,1));
    j = 1;

    firstInd = find(analyzed(:,2),1, 'first');
    t1 = analyzed(firstInd,1);

    for i=firstInd+1:1:s
        if (analyzed(i,2) ~= 0)
            t2 = analyzed(i,1);
            int(j,1) = t2-t1;
            j=j+1;
            t1 = t2;
        end
    end
    
elseif prod(method == 'half')
    
    s = size(analyzed(:,1));
    k = 0;
    j = 1;
    for i=1:s
        if (analyzed(i,2) ~= 0) & (k==0)
            k =1;
            t1 = analyzed(i,1);
        elseif (analyzed(i,2) ~= 0) & (k==1)
            k =0;
            t2 = analyzed(i,1);
            int(j,1) = t2-t1;
            j=j+1;
        end
    end
else
    disp('Unknown method.');
    return;
end
end
 
     
