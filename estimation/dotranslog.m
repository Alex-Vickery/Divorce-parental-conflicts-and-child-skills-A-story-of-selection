%-------------------------------------------------------------------------%
% dotranslog.m
% Purpose:  Estimates the translog production function for all 251
%           bootstrap samples (bs=0 is the baseline, bs=1..250 are
%           bootstrap replicates). Calls translog.m which runs the EM
%           algorithm and saves results to output/estimates/PF_<bs>.mat.
% Inputs:   output/estimates/boot.mat
%           output/estimates/DATAoriginal.mat  (via getdata)
%           output/estimates/DATAmodel.mat     (via getdata)
% Outputs:  output/estimates/PF_0.mat ... PF_250.mat
%-------------------------------------------------------------------------%
clearvars;
global root_dir

estimates_dir = fullfile(root_dir, 'output', 'estimates');

% load bootstrap info
load(fullfile(estimates_dir, 'boot.mat'), 'numbssamples');
R = 1;

% Estimate the model for each bootstrap sample
for bs = 0:numbssamples

    pf = cellstr(strcat({'translog '}, string(1)));
    D = getdata(bs, R, pf{1});
    saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', bs));

    if ~exist(saveloc, 'file')
        est = struct;

        % preallocate the starting parameters - guess sensible values
        est.tfp = 0.1*ones(1,8); % the constant term
        est.retscal = [ones(1,2) ones(1,6)]; % returns to scale (can set to 1 to not estimate)
        % construct impelas - dimensions size(INPT,2) * numF
        est.inptelas = zeros(size(D.INPT,2), 8);
        % fill in in blocks of 9
        est.inptelas(8,1:2) = 2.5*ones(1,2); % first period conflicts
        est.inptelas(1:9,3:4) = 2.5*ones(9,2);
        est.inptelas(10:18,5:6) = 2.5*ones(9,2);
        est.inptelas(19:27,7:8) = 2.5*ones(9,2);
        est.var = 100*ones(1,8);
        est.tfperr = [0.1*ones(1,3);-0.1*ones(1,3);0.2*ones(1,3);-0.2*ones(1,3); zeros(1,3)];
        est.tfperrcoef = [1 1 zeros(1,6);
            0 0 1 0 1 0 1 0;
            0 0 0 1 0 1 0 1];
        est.typecoef = [-1.1 -0.2 -0.7 -1];

        % conflict equations
        est.bta = 0.001*ones(29,1);
        est.eta = 200;

        % divorce equation
        est.alpha = [0.02;0.01*ones(29,1)];
        est.pr = zeros(1,5);

        if strcmp(pf{1}, 'translog 1')
            est.tfpcoef = [repmat({0.001*ones(29,1)},1,2), repmat({0.001*ones(29,1)},1,6)];
        elseif strcmp(pf{1}, 'ces 2')
            est.tfpcoef = repmat({[-0.5; zeros(10,1)]},1,8);
        end
        save(saveloc, 'est');
    end

    load(saveloc, 'est');
    translog(D.Y, D.INPT, D.INPT2, D.typeX, D.tfpX, est, saveloc);
    fprintf("Bootstrap rep %d complete\n", bs)

end
