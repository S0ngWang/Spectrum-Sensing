function [availablity] = isavailable(S)
    if sum(S) > 0
        availablity = -1;
    else
        availablity = 1;
    end
end