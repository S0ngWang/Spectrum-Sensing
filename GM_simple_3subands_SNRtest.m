%% Initialization
clear;
close all;
clc;

%% Parameters
K = 5;  % Number of subbands
N = 2 * K; % Number of nodes
S = 2;  % Number of states: 1 for idle, 2 for occupied
acc_list = [];

for r = 1:21
    seq_size = 5000;
    test_size = 5000;
    
    dep = zeros(N, N);
    for i = 2:2:N - 2
        dep(i, i - 1) = 1;
        dep(i, i + 2) = 1;
    end
    dep(N, N - 1) = 1;
    dep = dep + dep';
    
    %% Contruct graphical model
    edgeStruct = UGM_makeEdgeStruct(dep, S);    % Structrual description
    
    %% Load samples
    load('tstate_mat.mat');
    load('obstate_mat.mat');
    
    seq = zeros(10000, N);
    for i = 1:K
        seq(:, i*2-1) = obstate_mat(:, i, r);
        seq(:, i*2) = tstate_mat(:, i, r);
    end
    seq = seq';
    
    edgeStruct.maxIter = seq_size;
    test_seq = seq(:, seq_size:seq_size + test_size);
    seq = seq(:, 1:seq_size);
    
    %% Training Parameters
    % Exact log-likelihood maxmization
    nodeMap = zeros(N, S);
    for i = 1:K
        nodeMap(2*i-1, :) = [i 0];
        nodeMap(2*i, :) = [i 0];
    end
    
    edgeMap = zeros(S, S, N - 1);  % Define edgeMap that map elements in edge_pot to training vector
    count = K + 2;
    for i = 1:N - 1
        if rem(i, 2) == 0
            edgeMap(1, 1, i) = count;
            edgeMap(2, 2, i) = count;
            count = count + 1;
        else
            edgeMap(1, 1, i) = K + 1;
            edgeMap(2, 2, i) = K + 1;
        end
    end
    
    nParams = max([nodeMap(:);edgeMap(:)]);
    w = zeros(nParams,1);   % Training vector that consists of elements from node_pot and edge_pot
    
    tic;
    suffStat = UGM_MRF_computeSuffStat(seq',nodeMap,edgeMap,edgeStruct);    % Calculate sufficient statistic
    w = minFunc(@UGM_MRF_NLL,w,[],edgeStruct.maxIter,suffStat,nodeMap,edgeMap,edgeStruct,@UGM_Infer_Exact);  % Gradient descent with exact inference
    [node_pot_est,edge_pot_est] = UGM_MRF_makePotentials(w,nodeMap,edgeMap,edgeStruct);
    toc;
    
    node_pot_est = node_pot_est ./ (sum(node_pot_est, 2) * ones(1, S));
    
    %% Inference & Evaluation
    err_count = 0;
    
    for i = 1:test_size
        state_vec = test_seq(:, i);
        clamped = zeros(N, 1);
        for j = 1:N
            if rem(j, 2) ~= 0
                clamped(j) = state_vec(j);
            end
        end
        
        decode_result = UGM_Decode_Conditional(node_pot_est,edge_pot_est, edgeStruct,clamped,@UGM_Decode_Exact);
        
        if sum(decode_result == state_vec) ~= N
            err_count = err_count + 1;
        end
    end
    accuacry = 1 - err_count / test_size;
    acc_list = [acc_list accuacry];
    
    fprintf('\nInference accuracy: %.2f\n\n', accuacry);
end

figure(1);
plot(-20:2:20, acc_list);
ylim([0 Inf]);