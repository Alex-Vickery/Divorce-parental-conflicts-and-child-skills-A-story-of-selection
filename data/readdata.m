%-------------------------------------------------------------------------%
% readdata.m
% Purpose:  Reads and cleans the raw MCS sample data, constructs bootstrap
%           resampling indices, and saves the processed dataset.
% Inputs:   data/sample_data.csv  (must be obtained from UK Data Service)
% Outputs:  output/estimates/DATAoriginal.mat
%           output/estimates/boot.mat
%-------------------------------------------------------------------------%
clearvars;
global root_dir

%-------------------------------------------------------------------------%
% Read in Data, Sort, Check IDs

indiv = readtable(fullfile(root_dir, 'data', 'sample_data.csv'), ...
    'Delimiter', ',', 'ReadVariableNames', true);

indiv = sortrows(indiv, 'mcsid', 'ascend');
id = indiv.mcsid;

N = numel(id);
if ~(numel(unique(id)) == numel(id)), error('non-unique ids'); end

% skills - cog3 cog5 cog7 cog12, noncog ''
% conflicts - f1m
% divorce - sep2

Wsk1 = [indiv.cog3, indiv.noncog3];
Wsk2 = [indiv.cog5, indiv.noncog5];
Wsk3 = [indiv.cog7, indiv.noncog7];
Wsk4 = [indiv.cog12, indiv.noncog12];

conflict = indiv.f1m;
divorce = indiv.sep2;
X = [];

X = [X double(cellfun(@(x) strcmpi(x, 'Female'), indiv.cm_female)) indiv.birth_weight]; % child controls 1:2
X = [X indiv.sib indiv.cohabiting indiv.duration double(cellfun(@(x) strcmpi(x, 'Planned Pregnancy'), indiv.plan_preg)) indiv.mother_rel indiv.mother_age indiv.father_age indiv.mother_etn1 indiv.father_etn1]; % demographic controls 3:11
X = [X indiv.mother_education41 indiv.mother_education42 indiv.mother_education43 indiv.father_education41 indiv.father_education42 indiv.father_education43]; % parents ed 12:17
X = [X indiv.mother_health11 indiv.father_health11]; % parents health 18:19
X = [X log(indiv.oecd_inc_birth) indiv.house_ten12 indiv.house_ten13 indiv.mother_nssec12 indiv.mother_nssec13 indiv.mother_nssec14 indiv.father_nssec12 indiv.father_nssec13 indiv.father_nssec14]; % financial resources 20:28

%-------------------------------------------------------------------------%
% Bootstrap samples
clustid = [double(cellfun(@(x) strcmpi(x, 'Female'), indiv.cm_female)), indiv.sep2];
[C,~,clustid] = unique(clustid(:,1:2), 'rows');
a_counts = accumarray(clustid, 1);
value_counts = [C, a_counts];
numclust = max(clustid);
numbssamples = 250;
bsrowrep = zeros(N, numbssamples+1);
rng(10)
for bs = 0:numbssamples
    if bs == 0
        bsrowrep(:,bs+1) = (1:1:N)';
    else
        rcnt = 0;
        for i = 1:numclust
            rand_clust = randsample(find(clustid == i), a_counts(i), true);
            rcnt = rcnt + a_counts(i);
            if i == 1
                bsrowrep(1:rcnt, bs+1) = rand_clust;
            else
                bsrowrep(rcnt-(a_counts(i)-1):rcnt, bs+1) = rand_clust;
            end
        end
    end
end

%-------------------------------------------------------------------------%
% Save results
estimates_dir = fullfile(root_dir, 'output', 'estimates');

save(fullfile(estimates_dir, 'DATAoriginal.mat'), ...
    'id', 'X', 'conflict', 'divorce', ...
    'Wsk1', 'Wsk2', 'Wsk3', 'Wsk4', ...
    'bsrowrep');

% save number of bootstrap samples separately
save(fullfile(estimates_dir, 'boot.mat'), 'numbssamples');
