function nPerBinInBursts = numberPerBinInsideBursts(eventi, binLength)

%%Date: 2019-05-19 Last Modification: 2019-05-19
%Author: D. Decastri
%
%this function returns the distribution of the number of switch per bin
%inside the bursting events given in input as a cell array 'eventi' 
%containing the matrices of the data of the measurement, with times in the
%first column and '0' or '1' in the penultimate column.

colBoole = size(eventi{1,1},2)-1;
nPerBinInBursts = [];

for i = 1:size(eventi,2)
    if eventi{1,i}(end,1) - eventi{1,i}(1,1) >= binLength
        nPerBinPartial = numberPerBin(eventi{1,i}, 1, colBoole, binLength);
        nPerBinInBursts = [nPerBinInBursts; nPerBinPartial];
    end
    
    if size(nPerBinInBursts,1) == 0
        disp('The bin length is bigger than the duration of all the bursts.');
        return
    end
    %ALTERNATIVA
    %if eventi{1,i}(end,1) - eventi{1,i}(1,1) <= binLength
    %    nPerBinPartial = numberPerBin(eventi{1,i}, col, colBoole, binLength);
    %else 
    %    nPerBinPartial = sum(eventi{1,i}(:,colBoole));
    %end
    %nPerBinInBursts = [nPerBinInBursts; nPerBinPartial(:,3)];
end

end
