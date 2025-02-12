function sttc_barcodes(filename1,filename2,filename3)

subplot(3,1,1)
dat = load(filename1);
dat = dat.group1;
dat = [dat(:,1)-dat(1,1),dat(:,2)];
iniz = dat(1,1);
%dat(dat(:,2)==1,1)
axis([iniz,300+iniz,0,1])
gridxy(dat(dat(:,2)==1,1)')

subplot(3,1,2)
dat = load(filename2);
dat = dat.group1;
dat = [dat(:,1)-dat(1,1),dat(:,2)];
iniz = dat(1,1);
%dat(dat(:,2)==1,1)

axis([iniz,300+iniz,0,1])
gridxy(dat(dat(:,2)==1,1)')
subplot(3,1,3)
dat = load(filename3);
dat = dat.group1;
dat = [dat(:,1)-dat(1,1),dat(:,2)];
iniz = dat(1,1);
%dat(dat(:,2)==1,1)
axis([iniz,300+iniz,0,1])
gridxy(dat(dat(:,2)==1,1)')



end