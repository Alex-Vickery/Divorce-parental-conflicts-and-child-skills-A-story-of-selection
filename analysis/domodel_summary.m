%-------------------------------------------------------------------------%
% domodel_summary.m
% Purpose:  Produces model fit figures (Figures A.3-A.4) and the divorce
%           gaps table (Table A.14) by calling divorce_gaps and model_fit.
% Inputs:   output/estimates/PF_0.mat  (via estimates_dir)
%           output/estimates/DATAoriginal.mat  (via getdata)
%           output/estimates/DATAmodel.mat     (via getdata)
% Outputs:  output/tables/divorce_gaps.tex
%           output/figures/model_fit_divorce*.pdf
%           output/figures/model_fit_no_divorce*.pdf
%-------------------------------------------------------------------------%
clearvars;
global root_dir

estimates_dir = fullfile(root_dir, 'output', 'estimates');
tables_dir    = fullfile(root_dir, 'output', 'tables');
output_dir    = fullfile(root_dir, 'output');

rng('default');

%-----------------------------------------------
% Part 0: load in the data and the parameter estimates
%-----------------------------------------------
pf = cellstr(strcat({'translog '},string(1)));
saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', 0));
load(saveloc,'est'); % load initial estimates
D = getdata(0,1,pf{1}); % and the initial baseline data

%-----------------------------------------------
% Part 1: Replicate observed divorce gaps
%-----------------------------------------------
saveloc = fullfile(tables_dir, 'divorce_gaps.tex'); % where to save the table
divorce_gaps(D, est, saveloc)

%-----------------------------------------------
% Part 2: Model fit
%-----------------------------------------------
model_fit(D, est, output_dir);
