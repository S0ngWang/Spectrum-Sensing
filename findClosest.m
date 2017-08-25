function [idx_list] = findClosest(Y_list, alpha)
    K = size(alpha, 1);
    R = size(Y_list, 1);
    idx_list = zeros(R, 1);
    
    for i = 1:R
        mindis = Inf;
        mink = Inf;
        for j = 1:K
            dis = sum((Y_list(i, :) - alpha(j, :)) .^ 2);
            if dis < mindis
                mindis = dis;
                mink = j;
            end
        end
        idx_list(i) = mink;
    end
end