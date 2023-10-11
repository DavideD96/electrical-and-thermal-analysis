function nPerBin = numberPerBin(valutato, colT, colBoole, binLength)

%This function returns a matrix wich column 1 contains the times at wich
%start the intervals, column 2 the time at wich end the intervals, and column
%3 the number of swithces in each interval.
%
%   valutato: matrix containing the times of the measures in column 1, the
%             results of the measures in column 2 and in column 3, 1 or 0 
%             depending on whether corresponding to the measure at that 
%             time there is a switch or not.
%
%   colT: number of the column containing the times of the mesures.
%
%   colBoole: number of the column containing 0 if there isn't a switch and
%             1 if there is a switch.
%
%   binLength: lenght in time of the bins.
%

k=1;
i=1;
while (valutato(1,colT)+binLength*k)<valutato(end,colT)
    [vect, indIn, indFin] = extract_p(valutato(:,colT), valutato(1,colT)+binLength*(k-1),...
        valutato(1,colT)+binLength*k);
    if ~isempty(vect)
        numb = sum(valutato(indIn:indFin,colBoole) == 1);
        nPerBin(i, 1) = valutato(indIn,colT);
        nPerBin(i, 2) = valutato(indFin,colT);
        nPerBin(i, 3) = numb;
        i = i + 1;
    end
    k=k+1
end


end