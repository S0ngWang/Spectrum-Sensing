%% Initialization
clear;
close all;
clc;

%% Parameters
K = 5; % Number of subbands
H = 3; % Number of factor nodes
S = 2; % Number of states
R = 500;   % Size of training set
T = 500;   % Size of testing set
M = 100;    % Max Iteration

edges = [ 1 1 1 0 0;
          1 0 0 1 1;
          0 1 0 1 1  ];

%% Load samples
    load('tstate_mat.mat');
    load('obstate_mat.mat');
      
%% Training & Testing
for r = 1:1
    tstate_vec = tstate_mat(:, :, r);
    tstate_vec = tstate_vec - 1;
    obstate_vec = tstate_mat(:, :, r);
    obstate_vec = obstate_vec - 1;
    
    tstate_train = tstate_vec(1:R, :);
    tstate_test = tstate_vec(R+1:R+T, :);
    obstate_test = obstate_vec(R+1:R+T, :);
    
    f_list = Inf * ones(2 ^ max(sum(edges, 2)), H);
    for i = 1:H
        edge = edges(i, :);
        
        f_vec = [];
        for j = 1:K
            if edge(j) ~= 0
                f_vec = [f_vec tstate_train(:, j)];
            end
        end
        f_vec = bi2de(f_vec);
        
        for j = 1:R
            idx = f_vec(j) + 1;
            if f_list(idx, i) == Inf
                f_list(idx, i) = 1;
            else
                f_list(idx, i) = f_list(idx, i) + 1;
            end
        end
    end
    f_list = f_list / R;
    
    %% Testing
    for i = 1:2
        test_sample = obstate_test(i, :);
        bl_list = zeros(K, S);
        for j = 1:K
            bl_list(j, test_sample(j) + 1) = 1;
        end
        
        for j = 1:M
            f_bl_mat = Inf * ones(max(sum(edges, 2)), 2, H);
            for h = 1:H     % Forward from belief node to factor node
                count = 1;
                for k = 1:K
                    if edges(h, k) == 1
                        f_bl_mat(count, :, h) = bl_list(k, :);
                        count = count + 1;
                    end
                end
            end
            
            bl_pool = -1 * ones(max(sum(edges, 1)), S, K);
            bl_ptr = ones(K, 1);
            for h = 1:H     % Feedback of every factor node
                edge = edges(h, :);
                edge = find(edge == 1);
                for k = 1:length(edge)    % !!Feedback for every belief node
                    bl_k = zeros(S, 1);
                    for f = 1:size(f_list, 1)
                        f_bi = de2bi(f - 1, max(sum(edges, 2)));
                        blf = f_list(f, h);
                        for m = 1:max(sum(edges, 2))
                            if m ~= k
                                blf = blf * f_bl_mat(m, f_bi(m) + 1, h);
                            end
                        end
                        bl_k(f_bi(k) + 1) = bl_k(f_bi(k) + 1) + blf;
                    end
                    bl_k = bl_k / sum(bl_k);
                    bl_pool(bl_ptr(edge(k)), :, edge(k)) = bl_k;
                    bl_ptr(edge(k)) = bl_ptr(edge(k)) + 1;
                end
            end
            
            for k = 1:K     % Update belief at belief node
                count = 0;
                bl_list(k, :) = zeros(1, S);
                for s = 1:S
                    if bl_pool(s, 1, k) ~= -1
                        bl_list(k, :) = bl_list(k, :) + bl_pool(s, :, k);
                        count = count + 1;
                    end
                end
                bl_list(k, :) = bl_list(k, :) / count;
            end
        end
    end
end
