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
acc_list = zeros(21, 1);

%% Load dataset
load('tstate_mat.mat');
load('obstate_mat.mat');

for r = 1:21
    seq = bi2de(obstate_mat(:, :, r) - 1) + 1;
    tstate = bi2de(tstate_mat(:, :, r) - 1) + 1;
    
    train_seq = seq(1:5000);
    train_state = tstate(1:5000);
    
    %% Train HMM on training sequence
    tic;
    [trans_est, emis_est]= hmmestimate(train_seq, train_state);
    %      [trans_guess, emis_guess] = hmmestimate(train_seq, train_seq);  % Estimate transition matrix and emission matrix with sensing result and estimated states
    %      [trans_est, emis_est] = hmmtrain(train_seq, trans_guess, emis_guess);
    toc;
    est_time = toc;
    
    trans_est = trans_est + (trans_est == 0) * 1e-10;
    emis_est = emis_est + (emis_est == 0) * 1e-10;
    
    tic
    psstate_prob = hmmdecode(seq', trans_est, emis_est);    % Inference
    toc;
    infr_time = toc;
    
    psstate = zeros(R, 1);
    
    for i = 1:R
        psstate(i) = find(psstate_prob(:, i) == max(psstate_prob(:, i)));
    end
    
    %% Calculate accurcy
    accurcy = sum(psstate(T + 1:end) == tstate(T + 1:end)) * 100 / 5000;
    acc_list(r) = accurcy;
    
    fprintf('%d subbands, %d states, Prediction accurcy: %.2f%%\n\n',K, N, accurcy);
end