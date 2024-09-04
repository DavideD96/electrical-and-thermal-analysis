function std_ = estimateNoiseIFOV(coordx, coordy)

cd termoFiles_mat
    m = load("mtotalT.mat");
    m = m.mtotalT;
cd ..

m_ = zeros(size(m,3),1);

m_(:) = m(coordx,coordy,:);

plot(m_)
pause
[x,~] = ginput(2);

std_ = std(m_(x(1):x(2)));

end