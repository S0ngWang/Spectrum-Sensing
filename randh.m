function [h] = randh(M, N, mu)
    h = zeros(M, N);
    for i = 1:M
        for j = 1:N
            h(i, j) = random('norm', mu, 2);
        end
    end
end