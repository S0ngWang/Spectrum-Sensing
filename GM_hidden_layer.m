%% Initialization
clear;
close all;
clc;

%% Parameters
K = 2; % Number of subbands
S = 2; % Number of states
N = 5; % Number of nodes
R = 5000;   % Size of training sequence
T = 5000;   % Size of testing sequence

%% Contruct graphical model
dep = [0 0 1 0 0;
       0 0 1 0 0;
       1 1 0 1 1;
       0 0 1 0 0;
       0 0 1 0 0 ];
   
edgeStruct = UGM_makeEdgeStruct(dep, S);
edgeStruct.maxIter = R;

%% Load samples
load('tstate_mat.mat');
load('obstate_mat.mat');

nodeMap = [ 1 0;
            2 0;
            3 0;
            1 0;
            2 0 ];
        
edgeMap = zeros(S, S, edgeStruct.nEdges);

for e = 1:edgeStruct.nEdges
    edgeMap(1, 1, e) = 3 + e;
    edgeMap(2, 2, e) = 3 + e;
end

%% Training
for r = 1:21
    tstate_vec = tstate_mat(:, :, r);
    obstate_vec = obstate_mat(:, :, r);
    
    nParams = max([nodeMap(:);edgeMap(:)]);
    w = zeros(nParams,1);   % Training vector that consists of elements from node_pot and edge_pot
    
    
end

