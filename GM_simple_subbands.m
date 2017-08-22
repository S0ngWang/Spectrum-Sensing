%% Initialization
clear;
close all;
clc;

%% Parameters
K = 6;  % Number of subbands
N = 2 * K;  % Number of nodes
S = 2;  % Number of states: 1 for idle, 2 for occupied
Sigma = 2;  % Noise power
SNR = 10; % Signal-to-noise ratio in dB
mu = qfunc(sqrt(Sigma * 10 ^ (SNR / 10) / 2 * Sigma));  % Detection error rate (AWGN channel)

seq_size = 10000;
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

node_pot = zeros(N, S);
for i = 1:N
    node_pot(i, :) = [.5 .5];
end

edge_pot = zeros(S, S, edgeStruct.nEdges);    % Pairwise dependencies

for i = 1:edgeStruct.nEdges
    if rem(i, 2) == 0
        edge_pot(:, :, i) = [ 2 1;
                              1 2 ];
    else
        edge_pot(:, :, i) = [1 - mu mu;
                             mu 1 - mu ];
    end
end

%% Sample Generate
edgeStruct.maxIter = seq_size;
seq = UGM_Sample_Exact(node_pot, edge_pot, edgeStruct);

test_seq = seq(:, 1:test_size);

%% Training Parameters
node_map = zeros(N, S);
for i = 1:N
    node_map(i, 1) = i;
end

edge_map = zeros(S, S, edgeStruct.nEdges);
for i = 1:edgeStruct.nEdges
    edge_map(1, 1, i) = N + i;
    edge_map(2, 2, i) = N + i;
end

nParams = max([node_map(:);edge_map(:)]);
w = zeros(nParams,1);

tic;
suffStat = UGM_MRF_computeSuffStat(seq',node_map,edge_map,edgeStruct);    % Calculate sufficient statistic
w = minFunc(@UGM_MRF_NLL,w,[],edgeStruct.maxIter,suffStat,node_map,edge_map,edgeStruct,@UGM_Infer_Exact);  % Gradient descent with exact inference
[node_pot_est,edge_pot_est] = UGM_MRF_makePotentials(w,node_map,edge_map,edgeStruct);
toc;

node_pot_est = node_pot_est ./ (sum(node_pot_est, 2) * ones(1, S));

%% Inference & Evaluation
err_count = 0;

for i = 1:test_size
    state_vec = test_seq(:, i);
    clamped = zeros(N, 1);
    for j = 1:N
        if rem(j, 2) == 0
            clamped(j) = state_vec(j);
        end
    end
    
    decode_result = UGM_Decode_Conditional(node_pot_est,edge_pot_est, edgeStruct,clamped,@UGM_Decode_Exact);
    
    if sum(decode_result == state_vec) ~= N
        err_count = err_count + 1;
    end
end
fprintf('\nInference accuracy: %.2f\n\n', 1 - err_count / test_size);