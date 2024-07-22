function find_start_stop(frame1,frame2)

close all
cd termoFiles_mat
m = load("mtotalT.mat");
m = m.mtotalT;
cd ..

imagesc(m(:,:,frame1)-m(:,:,frame2));
colorbar

end
