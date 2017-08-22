%% Initialization
clear;
close all;
clc;

%% Parameters
load('tstate_mat.mat');
load('obstate_mat.mat');

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