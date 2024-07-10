
data = load("detection.mat");
data = data.ans.isi;

[isto, edg] = histcounts(data);

isto(isto == 0) = 1;

cent = edg(1,1:end-1);
diff = edg(2)-edg(1);

cent = cent + diff/2;

istolog = log10(isto);
centlog = log10(cent);

plot(centlog,istolog);
