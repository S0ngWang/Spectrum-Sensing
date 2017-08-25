function [K] = numberofK(M)
    k_sum = 0;
    for i = 0:M
        k = nchoosek(M, i);
        k_sum = k_sum + k;
    end
    K = k_sum;
end