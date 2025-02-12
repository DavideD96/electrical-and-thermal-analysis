function plot_CM(folders)

%y = zeros(1010,length(folders));

a = figure;
hold on

adjust = [+1,1,+1,-2,-1];

for ii = 1:length(folders)
    
    cd(folders{ii})
    cd termoFiles_mat

    y = load("cm_Y.mat");
    y = y.Y;
    y = y+adjust(ii);
    x = linspace(1,length(y),length(y))/50;

    plot(x,y)
    cd ..
    cd ..

end

grid on
legend({'1','2','3','4','5',})
xlim([0,x(end)])

savefig(a,'centre_of_mass_Y.fig')
end