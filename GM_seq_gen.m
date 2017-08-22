%% Initialization
clear;
clc;
close all;

%% Parameters
seq_size = 10000;
SNR_grad = -20:2:20;
mu = [1 1 1 1 1];
sigma = [ 1 .8 .8 .8 .8
         .8  1 .8 .8 .8
         .8 .8  1 .8 .8
         .8 .8 .8  1 .8
         .8 .8 .8 .8  1];
obstate_mat = zeros(seq_size, 5, length(SNR_grad));
tstate_mat = zeros(seq_size, 5, length(SNR_grad));

for i = 1:length(SNR_grad)
    %% Sequence generation
    SNR = SNR_grad(i);
    r = mvnrnd(mu, sigma, seq_size);
    tstate = r > 1;
    tstate = tstate + 1;
    obstate = awgn(tstate, SNR);
    obstate = obstate > 1.5;
    obstate = obstate + 1;
    
    tstate_mat(:, :, i) = tstate;
    obstate_mat(:, :, i) = obstate;
end

%% Save generated data
save('tstate_mat.mat', 'tstate_mat');
save('obstate_mat.mat', 'obstate_mat');