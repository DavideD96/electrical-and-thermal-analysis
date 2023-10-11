x = {linspace(-2,3,51),linspace(-3,3,61)};
[xx,yy] = ndgrid(x{1},x{2}); 
y = peaks(xx, yy);
noisy = y + (rand(size(y)) - 0.5);
figure
surf(xx,yy,noisy)
[sval,p] = csaps(x,noisy,[],x);
figure
surf(x{1},x{2},sval.')
disp('ciao')
disp('prova')
