%% Initialization
clear;
close all;
clc;

%% Parameters
K = 4;  % Number of subbands
S = 2;  % Number of states: 1 for idle, 2 for occupied
Sigma = 2;  % Noise power
acc_list = [];

for r = 1:21
    seq_size = 10000;
    test_size = 5000;
    
    dep = ones(K, K);  % Strutrual dependencies
    for i = 1:K
        dep(i, i) = 0;
    end
    
    %% Contruct graphical model
    edgeStruct = UGM_makeEdgeStruct(dep, S);    % Structrual description
    
    %% Load samples
    load('tstate_mat.mat');
    load('obstate_mat.mat');
    
    seq = zeros(seq_size, K);
    seq(:, 1) = obstate_mat(:, 1, r);
    seq(:, 2) = tstate_mat(:, 1, r);
    seq(:, 3) = tstate_mat(:, 2, r);
    seq(:, 4) = obstate_mat(:, 2, r);
    seq = seq';
    
    edgeStruct.maxIter = seq_size;
    test_seq = seq(:, 1:test_size);
    
    %% Training Parameters
    % Exact log-likelihood maxmization
    nodeMap = [ 1 0;    % Define nodeMap that map elements in node_pot to training vector
        1 0;
        2 0;
        2 0 ];
    
    edgeMap = zeros(S, S, K);  % Define edgeMap that map elements in edge_pot to training vector
    edgeMap(1,1,1) = 3;
    edgeMap(2,2,1) = 3;
    edgeMap(1,1,6) = 3;
    edgeMap(2,2,6) = 3;
    edgeMap(1,1,3) = 4;
    edgeMap(2,2,3) = 4;
    edgeMap(1,1,4) = 5;
    edgeMap(2,2,4) = 5;
    edgeMap(1,1,2) = 6;
    edgeMap(2,2,2) = 6;
    edgeMap(1,1,5) = 7;
    edgeMap(2,2,5) = 7;
    
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
        clamped = [state_vec(1);
            0;
            0;
            state_vec(4)];
        
        decode_result = UGM_Decode_Conditional(node_pot_est,edge_pot_est, edgeStruct,clamped,@UGM_Decode_Exact);
        
        if sum(decode_result == state_vec) ~= K
            err_count = err_count + 1;
        end
    end
    accruacy = 1 - err_count / test_size;
    acc_list = [acc_list accruacy];
    fprintf('\nInference accuracy: %.2f\n\n', 1 - err_count / test_size);
end

figure(1)
plot([-20:2:20], acc_list);
ylim([0 Inf]);