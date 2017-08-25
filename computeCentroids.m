function alpha_list = computeCentroids(Y_list, idx_list, k)
    N = size(Y_list, 2);
    R = size(Y_list, 1);
    alpha_list = zeros(k, N);
    count = zeros(k, 1);
    
    for i = 1:R
        j = idx_list(i);
        alpha_list(j, :) = alpha_list(j, :) + Y_list(i, :);
        count(j) = count(j) + 1;
    end
    
    count = count * ones(1, N);
    alpha_list = alpha_list ./ count;
end