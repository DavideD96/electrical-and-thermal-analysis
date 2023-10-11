function [mv, sv] = sigmaSelector(R,matSigma)

%Date: 2019-02-19 Last Modification: --
%
%   [mv,sv] = sigmaSelector(R,matSigma)
%The script select the interval in which R value is found and select the
%correspondent the mean (mv) and sigma (sv) value; to properly work, the
%matrix sigma matrix has to be ORDERED form the GREATER to the SMALLER value 
%of the innterval
%
%   R: the value to be compared with the intervals in the first raw of matSigma
%   matSigma: a matrix of 2 columns and n rows, where the first column
%             rapresent the values of the quantity intervals and the second
%             one the sigma associated to each quantity values
%
s = size(matSigma,1);

if s > 1
    if R > matSigma(1,1)/2
        mv = matSigma(1,1);
        sv = matSigma(1,2);
    elseif R < matSigma(s,1)/2
        mv = matSigma(s,1);
        sv = matSigma(s,2);
    else
        for k=1:s-1
            if (R <= matSigma(k,1)/2 & R >= matSigma(k+1,1)/2)
                mv = matSigma(k+1,1);
                sv = matSigma(k+1,2);
                break;
            end
        end
    end
else
    mv = matSigma(1);
    sv = matSigma(2);
end

end
