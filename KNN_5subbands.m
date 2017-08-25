%% Initialization
clear;
close all;
clc;

%% Parameters
K = 5; % Number of subbands
T = 5000; % Number of testing set
R = 5000; % Number of training set
KN = 5; % K nearest

%% Load training and testing data
load('tstate_mat.mat');
load('power_mat.mat');

%% Train & Test
acc_list = zeros(21, 1);

for r = 1:21
    power_list = power_mat(:, :, r);
    tstate_list = tstate_mat(:, :, r);
    tstate_list = tstate_list - 1;
    tstate_list = bi2de(tstate_list);
    
    power_train = power_list(1:R, :);
    power_test = power_list(R + 1:R + T, :);
    
    tstate_train = tstate_list(1:R, :);
    tstate_test = tstate_list(R + 1:R + T, :);
    
    pred_state_list = zeros(T, 1);
    
    for i = 1:T
        test_sample = power_test(i, :);
        dif = sum((power_train - test_sample).^2, 2);
        nn_list = zeros(KN, 2);
        
        for j = 1:KN
            idx = find(dif == min(dif));
            nn_list(j, 1) = dif(idx);
            nn_list(j, 2) = tstate_train(idx);
            dif(idx) = Inf;
        end
        
        w_list = Inf * ones(KN, 2);  % [weight; tstate] 
        ptr = 1;
        for j = 1:KN
            state = nn_list(j, 2);
            if isempty(find(w_list(:, 2) == state, 1)) == 1
                w_list(ptr, 2) = state;
                dif_vec = nn_list(:, 2) == state;
                count = sum(dif_vec);
                w_list(ptr, 1) = sum(nn_list(:, 1) .* dif_vec) / count;
                ptr = ptr + 1;
            end
        end
        min_idx = find(w_list(:, 1) == min(w_list(:, 1)));
        pred_state_list(i) = w_list(min_idx, 2);
        
        acc = sum(pred_state_list == tstate_test) / T;
        acc_list(r) = acc;
    end
end

figure(1);
plot(-20:2:20, acc_list);
ylim([0 Inf]);
grid on;