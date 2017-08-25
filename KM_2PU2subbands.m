clear;
close all;
clc;

Omega = 30; % Number of frequency
Sigma = 2; % Noise power
K = 2; % Number of subbands
SNR = 30;

Occ_vec = zeros(K, 1); % 0 for idle, 1 for occupied
Occ_vec(1) = 1;
X = randi([0 1], Omega, 1);
%h = randh(K, 1, 1);
h = ones(Omega, 1);
Occ_mat = Occ_vec * ones(1, Omega / K);
Occ_mat = Occ_mat';
Occ_mat = Occ_mat(:);

Z = awgn(X .* Occ_mat .* h, SNR, Sigma);

figure(1)
stem(Z);

Z_mat = reshape(Z, [Omega / K, K]);
Y = sum(Z_mat .^ 2) * 2 / Sigma;

figure(2)
bar(Y);
