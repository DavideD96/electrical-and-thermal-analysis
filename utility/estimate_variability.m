function std_ = estimate_variability()

R = load("Data.mat");
R = R.R;

plot(R(:,4))
pause

[x,~] = ginput(2);

x = round(x);
dat = R(x(1):x(2),4);
std_ = std(dat);
end