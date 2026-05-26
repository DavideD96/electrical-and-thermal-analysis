function plot_t_single_pixel(row,col)

cd termoFiles_mat\
clear old
m = load("mtotalT.mat");
m = m.mtotalT;

T_single_pix = squeeze(m(row,col,:));
size(T_single_pix)

clear m
f = 1/51;
time = zeros(length(T_single_pix),1);

for ii = 1:length(T_single_pix)
    time(ii) = f*(ii-1);
end

figure
plot(time,T_single_pix)
grid on
cd ..
end