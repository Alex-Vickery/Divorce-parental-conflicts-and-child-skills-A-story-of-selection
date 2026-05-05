function Ydet = translog_ydet(szY, X, coef)
%-------------------------------------------------------------------------%
% translog_ydet.m
% Purpose:  Computes the TFP covariate component of log skill production
%           (X * beta for each skill equation with non-empty covariates).
% Arguments:
%   szY   - size vector [N, numF] from size(Y)
%   X     - 1 x numF cell array of TFP covariate matrices
%   coef  - 1 x numF cell array of TFP coefficient vectors
% Returns:
%   Ydet  - N x numF matrix of predicted TFP components
%-------------------------------------------------------------------------%

Ydet = zeros(szY);
for f = find(~cellfun('isempty', X))
    Ydet(:,f) = X{f}*coef{f};
end
