%% Initialization
clear;
close all;
clc;

%% Parameters
load('tstate_mat.mat');

load('power_mat.mat');

obstate_mat = zeros(size(tstate_mat));

seq_size = size(tstate_mat, 1);
K = size(tstate_mat, 2);

for i = 1:21
    power_vec = power_mat(:, :, i);
     obstate = power_vec > 1 + ones(seq_size, 1) * (sum(tstate_mat(:, :, i) == 1) / seq_size);
    obstate = power_vec > 1.5;
    obstate = obstate + 1;
    obstate_mat(:, :, i) = obstate;
end

comp_mat = tstate_mat == obstate_mat;
acc_list = zeros(size(tstate_mat, 3), 1);

for i = 1:size(tstate_mat, 3)
    for j = 1:size(tstate_mat, 1)     
        if sum(comp_mat(j, :, i)) == length(comp_mat(j, :, i))
            acc_list(i) = acc_list(i) + 1;
        end
    end
end

acc_list = acc_list / size(tstate_mat, 1);

plot([-20:2:20], acc_list);
ylim([0 Inf]);
grid on;