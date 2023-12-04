function matr = delete_zeros(matr)
    matr(1:5, : ,:) = [];
    matr(end-3:end, : ,:) = [];
    matr(:, 1:5 ,:) = [];
    matr(:, end-3:end ,:) = [];

end