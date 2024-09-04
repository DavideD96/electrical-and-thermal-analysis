function nswicthThresh = deltaG_higherThan(s,threshold)

data = s.detection;
dataTresholded = data(abs(data(:,end))>threshold,end);
nswicthThresh = size(dataTresholded,1);

end