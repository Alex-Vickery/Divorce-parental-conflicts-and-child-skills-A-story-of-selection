function [ll,qi,pr0] = translog_like(est, Y, INPT, INPT2, typeX, tfpX)
%-------------------------------------------------------------------------%
% translog_like.m
% Purpose:  Computes the log-likelihood and posterior type probabilities
%           for the translog production function model.
% Arguments:
%   est     - struct of current parameter estimates
%   Y       - N x 8 skill outcomes
%   INPT    - N x 27 translog input terms
%   INPT2   - N x 2 [conflicts, divorce]
%   typeX   - N x 1 type covariates
%   tfpX    - 1 x 8 cell array of TFP covariates
% Returns:
%   ll      - scalar log-likelihood
%   qi      - N x numType posterior type weights
%   pr0     - N x numType prior type probabilities
%-------------------------------------------------------------------------%

% inpt2(:,2) == divorce, 1 is conflict

numType = size(est.tfperr,1);
N = size(Y,1);

% skill production
Yresid = Y - translog_lnpred(est, Y, INPT, INPT2) - translog_ydet(size(Y), tfpX, est.tfpcoef);

% need to pick out relevant TFP parts
tfp = tfpX{1}(:,2:end);
% conflicts
Cresid = INPT2(:,1) - tfp*est.bta(2:29);

% Divorce equations
d_prob = glmval(est.alpha, [INPT2(:,1) tfp], 'logit', 'Size', 1);

expv = [exp(typeX*est.typecoef) ones(N,1)];
pr0 = bsxfun(@rdivide, expv, sum(expv,2));
like1 = zeros([N numType]);
for k = 1:numType
    typemean = est.tfp + est.tfperr(k,:)*est.tfperrcoef(:,1:8);
    like1(:,k) = mvnpdf(Yresid, typemean, est.var);
    typemean = est.bta(1);
    like1(:,k) = like1(:,k).*normpdf(Cresid, typemean, est.eta);
    like1(:,k) = like1(:,k).*(((d_prob).^INPT2(:,2)).*((1-d_prob).^(1-INPT2(:,2))));
    like1(like1(:,k) == 0,k) = eps;
end

like = like1.*pr0;

ll = sum(log(sum(like,2)));

qi = bsxfun(@rdivide, like, sum(like,2));
