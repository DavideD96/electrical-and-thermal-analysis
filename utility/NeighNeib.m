function yes_or_not = NeighNeib(a,b)

% a = [x,y]
% b = [x,y]

    a = round(a);
    b = round(b);

    if abs(a(1)-b(1)) <= 1 && abs(a(2)-b(2)) <= 1 %cioè NN
        yes_or_not = 1;
    else
        yes_or_not = 0;
    end

end