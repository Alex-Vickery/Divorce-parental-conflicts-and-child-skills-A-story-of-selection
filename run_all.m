%=========================================================================%
% run_all.m
% Master script for: Moroni & Vickery (2025)
% "Divorce, Parental Conflicts and Child Skills: A Story of Selection"
%
% Usage: Open MATLAB, navigate to this directory, and run this script.
%        All outputs are saved under output/.
%
% Note: Step 2 (EM estimation) takes a few hours of compute time depending 
%       on your machine.
%       Steps 3-5 can be run independently once Step 2 is complete.
%=========================================================================%

%--- 0. Setup ------------------------------------------------------------%
global root_dir
root_dir = fileparts(mfilename('fullpath'));

% Add all source directories to MATLAB path
addpath(fullfile(root_dir, 'data'));
addpath(fullfile(root_dir, 'estimation'));
addpath(fullfile(root_dir, 'analysis'));
addpath(fullfile(root_dir, 'functions'));

% Create output subdirectories if they don't exist
output_dirs = {
    fullfile(root_dir, 'output', 'estimates');
    fullfile(root_dir, 'output', 'figures');
    fullfile(root_dir, 'output', 'tables')
};
for i = 1:numel(output_dirs)
    if ~exist(output_dirs{i}, 'dir')
        mkdir(output_dirs{i});
    end
end

%--- Step 1: Data preparation --------------------------------------------%
fprintf('\n=== Step 1: Data preparation ===\n');
run(fullfile(root_dir, 'data', 'readdata.m'));
run(fullfile(root_dir, 'data', 'modeldata.m'));
fprintf('Step 1 complete.\n');

%--- Step 2: EM estimation -----------------------------------------------%
fprintf('\n=== Step 2: EM estimation (this may take several hours) ===\n');
run(fullfile(root_dir, 'estimation', 'dotranslog.m'));
fprintf('Step 2 complete.\n');

%--- Step 3: Parameter tables --------------------------------------------%
fprintf('\n=== Step 3: Tables ===\n');
run(fullfile(root_dir, 'analysis', 'make_tabs.m'));
fprintf('Step 3 complete.\n');

%--- Step 4: Model fit and divorce gaps ----------------------------------%
fprintf('\n=== Step 4: Model fit and divorce gaps ===\n');
run(fullfile(root_dir, 'analysis', 'domodel_summary.m'));
fprintf('Step 4 complete.\n');

%--- Step 5: Counterfactuals ---------------------------------------------%
fprintf('\n=== Step 5: Counterfactuals ===\n');
run(fullfile(root_dir, 'analysis', 'docfact.m'));
fprintf('Step 5 complete.\n');

fprintf('\n=== All steps complete. Outputs saved to output/ ===\n');
