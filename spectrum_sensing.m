%% Initialization
clear;
close all;
clc;

%% Parameters
M = 2; % Number of Primary users (PU)
N = 2; % Number of Secondary users (SU)
Omega = 30; % Number of samples
Sigma = 2; % Noise power
Iter = 1000; % Learning cycle
R = 1000; % Number of iternation
training_size = 800; % Size of training set
beta = 2; % Threshold of detection
K_s = 2; % Number of subbands (Assume every SU takes one subband when channel is avaibile)

h = randh(M, N, 1); % Channels between PUs and SUs
h_s = randh(N, N, 1); % Channels between SUs and SUs
h_s = tril(h_s);

for i = 1:N
    h_s(i, i) = 0;
end

h_s = h_s + h_s';

A_list = zeros(R, 1);
Y_list = zeros(R, N);
Y_s_list = zeros(R, N);
S_list = zeros(R, M);

%% Generate received signals and plot
for round = 1:R
    S = randi([0 1], M, 1); % State vector of primary users, (0, 1)
    S_list(round, :) = S;
    A_list(round) = isavailable(S);

    X = randi([0 1], M, Omega); % Signal of PUs

    S_mat = S * ones(1, N);
    Z = (S_mat .* h)' * X; 
    Z = awgn(Z, 10, Sigma); % Recieved signal of SUs
    
    % Let SU transmit at a subband when channel is avaibile
    if A_list(round) == 1
%         S_s = randi([0 1], N, 1);
%         X_s = randi([0 1], N, Omega / K_s);
%         X_s = [X_s zeros(N, Omega - Omega / K_s)];
%         
%         S_s_mat = S_s * ones(1, N);
%         Z_s = (S_s_mat .* h_s)' * X_s;
%         Z_s = awgn(Z_s, 10, Sigma);
%         Z = Z + Z_s;
        Y = sum(Z .^ 2, 2) * 2 / Sigma / 10;  % Power vector
        Y_s_list(round, :) = Y;
    else   
        Y = sum(Z .^ 2, 2) * 2 / Sigma / 10;  % Power vector
        Y_list(round, :) = Y;
    end
end

figure(1);
scatter(Y_list(:, 1), Y_list(:, 2));
hold on;
scatter(Y_s_list(:, 1), Y_s_list(:, 2), 'g');

% %% Initialize training parameters
% Y_list = Y_list + Y_s_list;
% Y_training = Y_list(1:training_size, :);
% Y_test = Y_list(training_size + 1:end, :);
% A_test = A_list(training_size + 1:end, :);
% 
% K = numberofK(M);   % Compute the number of clusters
% 
% %% Classify received signals using K-means and plot classification results
% randidx = randperm(training_size);
% alpha_list = Y_training(randidx(1:K), :);
% alpha1 = Omega * ones(1, N) * 2 / 100;
% alpha_list(1, :) = alpha1;
% 
% for i = 1:Iter
%     idx_list = findClosest(Y_training, alpha_list);
%     alpha_list = computeCentroids(Y_training, idx_list, K);
%     alpha_list(1, :) = alpha1;
% end
% 
% hold on;
% scatter(alpha_list(:, 1), alpha_list(:, 2), 'r', 'filled');
% 
% %% Use the training result to classify test set
% A_hyp = kmeansclassify(alpha_list, Y_test, beta);
% acc = A_hyp == A_test;
% acc = sum(acc) / (R - training_size) * 100.0;
% fprintf('Accurecy: %f%%\n', acc);
