function find_start_stop(frame1,frame2)

close all
m = load("mtotalT.mat");
m = m.mtotalT;

imagesc(m(:,:,frame1)-m(:,:,frame2));
colorbar

end
