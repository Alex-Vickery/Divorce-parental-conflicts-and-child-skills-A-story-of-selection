%-------------------------------------------------------------------------%
% modeldata.m
% Purpose:  Constructs the model-ready dataset from the processed raw data,
%           including production function inputs and factor model data.
% Inputs:   output/estimates/DATAoriginal.mat
%           output/estimates/boot.mat
% Outputs:  output/estimates/DATAmodel.mat
%-------------------------------------------------------------------------%
clearvars;
global root_dir

estimates_dir = fullfile(root_dir, 'output', 'estimates');

% load the data
D = load(fullfile(estimates_dir, 'DATAoriginal.mat'));
N = numel(D.id);  % sample size

% load bootstrap info
load(fullfile(estimates_dir, 'boot.mat'), 'numbssamples');

% Data on the Factors Model
%-------------------------------------------------------------------------%
W = [D.Wsk1 D.conflict D.divorce D.Wsk2 D.Wsk3 D.Wsk4];

% Production function data
%-------------------------------------------------------------------------%
tfpX = cell(1,8); % number of functions to estimate
for i = 1:8
    tfpX{i} = [D.divorce D.X];
end

typeX = ones(N,1);
typeXfull = [ones(N,1) D.X];
typeXfull(isnan(typeXfull)) = 0;

% Save model data
%-------------------------------------------------------------------------%
id = D.id;

save(fullfile(estimates_dir, 'DATAmodel.mat'), 'W', 'id', 'tfpX', 'typeX', 'typeXfull');
