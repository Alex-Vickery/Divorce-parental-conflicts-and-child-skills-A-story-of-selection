function D = getdata(bs, R, REASON)
%-------------------------------------------------------------------------%
% getdata.m
% Purpose:  Loads bootstrap-resampled data for estimation and simulation.
% Inputs:   bs      - bootstrap index (0 = baseline sample)
%           R       - replication factor for simulation draws
%           REASON  - string specifying which data format to return
%                     ('translog 1' or 'translog 2')
% Output:   D       - data structure
%-------------------------------------------------------------------------%
global root_dir

estimates_dir = fullfile(root_dir, 'output', 'estimates');

%% Rows in Bootstrap Sample
load(fullfile(estimates_dir, 'DATAoriginal.mat'), 'bsrowrep');

pickid = bsrowrep(:,bs+1);

%% Model Data
load(fullfile(estimates_dir, 'DATAmodel.mat'), 'W', 'id', 'tfpX', 'typeX', 'typeXfull');

W = W(pickid,:);

if nargin == 1

    D = W;

    return;

end

typeX = typeX(pickid,:);
tfpX = cellfun(@(x) x(pickid,:), tfpX, 'unif', 0);

%% Production function DATA
if strcmp(REASON, 'translog 1')

    idx = [1 2 5:1:10];
    D_PF.Y = W(:,idx);
    idx = [1 1 1 2 1 3 2 2 2 3 3 3; ...
        5 5 5 6 5 3 6 6 6 3 3 3;...
        7 7 7 8 7 3 8 8 8 3 3 3];
    numF = 3;
    D_PF.INPT = zeros(length(id), numF*9); % prod func inputs
    for i = 1:numF
        cog = [W(:,idx(i,1)), W(:,idx(i,2)).^2, W(:,idx(i,3)).*W(:,idx(i,4)), W(:,idx(i,5)).*W(:,idx(i,6))];
        emo = [W(:,idx(i,7)), W(:,idx(i,8)).^2, W(:,idx(i,9)).*W(:,idx(i,10))];
        conf = [W(:,idx(i,11)), W(:,idx(i,12)).^2];
        D_PF.INPT(:,i*9-8:i*9) = [cog, emo, conf];
    end

    idx = [3 4];
    D_PF.INPT2 = W(:,idx);
    D_PF.tfpX = cellfun(@(x) repmat(x,[R 1]), tfpX, 'unif', 0);
    D_PF.typeX = repmat(typeX, [R 1]);
    D = D_PF;
    return;

elseif strcmp(REASON, 'translog 2')
    D_PF = 1;
    D = D_PF;
    return;

end

end
