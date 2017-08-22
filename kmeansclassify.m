function A_hyp = kmeansclassify(alpha_list, Y_test, beta)
M = size(Y_test, 1);
K = size(alpha_list, 1);
A_hyp = zeros(M, 1);

for i = 1:M
    cluster1dis = sum((Y_test(i, :) - alpha_list(1, :)) .^ 2);
    mindis = Inf;
    for k = 2:K
        dis = sum((Y_test(i, :) - alpha_list(k, :)) .^ 2);
        if dis < mindis
            mindis = dis;
        end
    end
    
    if cluster1dis / mindis >= beta
        A_hyp(i) = -1;
    else
        A_hyp(i) = 1;
    end
end