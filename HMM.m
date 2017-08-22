%% Initialization
clear;
close all;
clc;

%% Parameters
K = 2;  % Number of maximum subbands
mu = 0.0571;

R = 10000;

N = 2 ^ K; % Number of states/results
T = R / 2;    % Number of trainning samples

%% Generate transmission matrix & emission matrix

trans_mat = zeros(N, N);

for i = 1:N
    randomNumbers = rand(1,N);
    sumOfNumbers = sum(randomNumbers);
    normalizedRandomNumbers = randomNumbers / sumOfNumbers;
    trans_mat(i, :) = normalizedRandomNumbers;
end

emis_mat = zeros(N, N);

% Generate emission matrix
for i = 1:N
    for j = 1:N
        errbit = sum(abs(dec2bin(i - 1, N) - dec2bin(j - 1, N)));
        emis_mat(i, j) = mu ^ errbit * (1 - mu) ^ (N - errbit);
    end
end

%% Generate random sequence and corrsponding states based on HMM as input
[sens_res, states] = hmmgenerate(R, trans_mat, emis_mat);
train_seq = sens_res(1:T);
% likelystates = hmmviterbi(train_seq, trans_mat, emis_mat); % Estimate states with Viterbi algorthim
% prior_accurcy = sum(likelystates == states) / T;

%% Train HMM on training sequence
tic;
[trans_est, emis_est]= hmmestimate(train_seq, train_seq);
%      [trans_guess, emis_guess] = hmmestimate(train_seq, train_seq);  % Estimate transition matrix and emission matrix with sensing result and estimated states
%      [trans_est, emis_est] = hmmtrain(train_seq, trans_guess, emis_guess);
toc;
est_time = toc;
est_list(K) = est_time;

trans_est = trans_est + (trans_est == 0) * 1e-10;
emis_est = emis_est + (emis_est == 0) * 1e-10;

tic
psstate_prob = hmmdecode(sens_res, trans_est, emis_est);    % Inference
toc;
infr_time = toc;
infr_list(K) = infr_time;

psstate = zeros(1, R);

for i = 1:R
    psstate(i) = find(psstate_prob(:, i) == max(psstate_prob(:, i)));
end

%% Calculate accurcy
accurcy = sum(psstate(T + 1:end) == states(T + 1:end)) * 100 / (R - T);

fprintf('%d subbands, %d states, Prediction accurcy: %.2f%%\n\n',K, N, accurcy);