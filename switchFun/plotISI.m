%plot and fit isi

data = load("detection.mat");
data = data.s.isi;
[isto, edg] = histcounts(data);

%isto(isto == 0) = 1;

cent = edg(1,1:end-1);
diff = edg(2)-edg(1);

cent = cent + diff/2;

isto(isto == 0) = [];
cent(isto == 0) = [];


istolog = log10(isto);
centlog = log10(cent);

plot(centlog,istolog,'-o');

P = polyfit(centlog,istolog,1);
yfit = P(1)*centlog+P(2);
hold on;
plot(centlog,yfit);

grid on
xlabel('log_{10}(ISI [s]/[s])')
ylabel('log_{10}(counts)')
annotation('textbox', [0.65, 0.8, 0.1, 0.1], 'String', append('ang coeff = ',num2str(P(1))));
hold off
