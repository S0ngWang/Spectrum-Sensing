%% Initialization
clear;
close all;
clc;

%% Parameters
K = 2;  % Number of maximum subbands
mu = 0.0571;

R = 5000;

N = 2 ^ K; % Number of states/results
T = 5000;    % Number of trainning samples
acc_list = zeros(21, 1);

%% Load dataset
load('tstate_mat.mat');
load('obstate_mat.mat');

for r = 1:21
    seq = bi2de(obstate_mat(:, :, r) - 1) + 1;
    tstate = bi2de(tstate_mat(:, :, r) - 1) + 1;
    
    train_seq = seq(1:R);
    train_state = tstate(1:R);
    
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
    
    psstate = zeros(R + T, 1);
    
    for i = 1:R + T
        psstate(i) = find(psstate_prob(:, i) == max(psstate_prob(:, i)), 1);
    end
    
    %% Calculate accurcy
    accurcy = sum(psstate == tstate) * 100 / (R + T);
    acc_list(r) = accurcy;
    
    fprintf('%d subbands, %d states, Prediction accurcy: %.2f%%\n\n',K, N, accurcy);
end

plot(-20:2:20, acc_list / 100);
ylim([0 Inf]);