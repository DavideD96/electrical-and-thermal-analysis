function [detrended, deg] = detrend_(x,y)

answer = inputdlg({'Enter the degree of the polynomial to fit. ("no" if you you do not want to detrend)'});
if answer{1}=="no"
    detrended = y;
    plot(x,detrended);
    deg = 0;
else
    deg = str2num(answer{1});
    disp([x,y]);
    coefficients = polyfit(x,y,deg);%uint64(degree));
    evaluated = polyval(coefficients, x);

    figure;
    subplot(2,1,1);
    plot(x, y, x, evaluated); 

    detrended = y - evaluated;
    subplot(2,1,2);
    plot(x,detrended);
    mean(detrended);
end
end