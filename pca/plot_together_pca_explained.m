function plot_together_pca_explained(mat,folders)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_files = length(folders);
volt = cell(1,n_files);

x_all = [];
y_all = [];
volt = [];

for kk = 1:n_files
    cd(folders{kk})
    
    listing = dir(pwd);
    nfiles = length(listing);
    groups = {};
    
    for ii = 1:nfiles
        nome = listing(ii).name;
        ind = strfind(nome,'V');
        if ind ~= 0
    
            % cerco modulo
            ind = ind-1;
            while isnan(str2double(nome(ind)))
                ind = ind-1;
            end
            
            voltage = str2double(nome(ind));
            % cerco segno
            if nome(ind-1) == '-'
                voltage = -voltage;
            end
        end
    
    end

    cd termoFiles_mat\

    name = [mat,'_pesi_.fig']; %mat = 'mtotalT'/'mtotalDT'
    figur = openfig(name);
    axObjs = figur.Children;
    dataObjs = axObjs.Children;

    % fig = gcf;
    % ax_ = gca;
    h = findobj(dataObjs,'Type','line');
    x = h.XData; 
    y = h.YData;

    volt{kk} = num2str(voltage);
    x_all = [x_all,x'];
    y_all = [y_all,y'];

    cd ..
    cd ..
end

y_all_diff = [y_all(1,:);diff(y_all,1,1)];

f = figure;
hold on
for kk = 1:n_files
    hold on
    plot(x_all(1:10,kk),y_all(1:10,kk),'-o')
end
ax = gca;
legend(volt)
xlabel('n° of Principal Components')
ylabel('Explained variance [%]')
grid on 

saveas(f,'cumul_explained_comparison.png','png')

f = figure;
hold on
for kk = 1:n_files
    hold on
    plot(x_all(1:10,kk),y_all_diff(1:10,kk),'-o')
end
legend(volt)
xlabel('Principal Components')
ylabel('Explained variance [%]')
grid on 

saveas(f,'explained_comparison.png','png')


hold off

end