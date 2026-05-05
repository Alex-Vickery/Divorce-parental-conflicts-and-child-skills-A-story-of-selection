function translog(Y, INPT, INPT2, typeX, tfpX, sv, saveloc)
%-------------------------------------------------------------------------%
% translog.m
% Purpose:  One outer EM iteration for the translog production function
%           model. Called by dotranslog.m. Internally calls em_alg2 which
%           iterates until convergence and saves checkpoints to saveloc.
% Arguments:
%   Y       - N x 8 matrix of log skill outcomes
%   INPT    - N x 27 matrix of translog input terms
%   INPT2   - N x 2 matrix [conflicts, divorce]
%   typeX   - N x 1 type classification covariates
%   tfpX    - 1 x 8 cell array of TFP covariates
%   sv      - struct of starting values / current estimates
%   saveloc - full path for checkpoint saves
%-------------------------------------------------------------------------%

if isempty(sv)
    sv = matfile(saveloc);
    sv = sv.est;
end

[numType,numErr] = size(sv.tfperr); % 5 x 3
[N,numF] = size(Y); % N x 8

LBinv = -2*((typeX'*typeX) \ speye(size(typeX,2)));

tfpXXinv = cellfun(@(x) (x'*x) \ speye(size(x,2)), tfpX, 'unif', 0);

[~,Rtec,rtec] = RLSestim([],[],sv.tfperrcoef(:));

function [est,ll] = calc(est)

    [ll,qi,pr0] = translog_like(est, Y, INPT, INPT2, typeX, tfpX);
    est.pr = pr0(1,:);

    gr = typeX'*(qi(:,1:end-1) - pr0(:,1:end-1));
    est.typecoef = est.typecoef - LBinv*gr;

    Eerr = qi*est.tfperr;
    err2 = bsxfun(@times, est.tfperr, reshape(est.tfperr,[numType 1 numErr]));
    Eerr2 = qi*reshape(err2,[numType numErr^2]);

    % prod technology
    Yresid = Y - Eerr*est.tfperrcoef - translog_ydet(size(Y), tfpX, est.tfpcoef);

    % Conflict equation
    tempX = [ones(N,1) tfpX{1}(:,2:end)];
    tempY = INPT2(:,1);
    est.bta = (tempX'*tempX)\(tempX'*tempY);
    est.eta = sqrt(var(INPT2(:,1) - tempX*est.bta));

    % Divorce equation
    tempX = [INPT2(:,1) tfpX{1}(:,2:end)];
    weights = zeros(length(INPT2(:,2)),1);
    weights(INPT2(:,2) == 1) = 1 ./ mean(INPT2(:,2));
    weights(INPT2(:,2) == 0) = 1 ./ (1-mean(INPT2(:,2)));
    est.alpha = glmfit(tempX, INPT2(:,2), 'binomial', 'Link', 'logit', 'weights', weights);

    for f = 1:numF
        b = struct('lntfp', est.tfp(f), 'retscal', est.retscal(f), ...
            'inptelas', est.inptelas(:,f));
        if b.retscal ~= 0
            b = translog2LVLmle(Yresid(:,f), INPT, INPT2, b, f);
        else
            b.lntfp = mean(Yresid(:,f));
        end
        est.tfp(f) = b.lntfp;
        est.retscal(f) = b.retscal;
        est.inptelas(:,f) = b.inptelas;
    end

    Yresid = Y - bsxfun(@plus, est.tfp, translog_lnpred(est, Y, INPT, INPT2)) ...
                 - translog_ydet(size(Y), tfpX, est.tfpcoef);
    x = Eerr;
    xx = reshape(sum(Eerr2,1),[numErr numErr]);

    XX = kron(diag(1./[est.var,est.eta,pi^2/3]), xx);
    XY = x'*bsxfun(@rdivide, Yresid, est.var);
    if any(~ismember(est.tfperrcoef(:),[0 1 -1]))
        est.tfperrcoef = reshape(RLSestim(XX,XY(:),[],Rtec,rtec), size(est.tfperrcoef));
    end

    for f = 1:numF
        y = Yresid(:,f);
        c = est.tfperrcoef(:,f);
        est.var(f) = (y'*y - 2*y'*(x*c) + c'*xx*c)/N;
    end

    Yresid = bsxfun(@rdivide, Yresid, sqrt(est.var));
    Yresid = bsxfun(@rdivide, qi'*Yresid, sum(qi)');

    x = bsxfun(@rdivide, est.tfperrcoef(1:3,1:8), sqrt(est.var));
    est.tfperr(1:end-1,1:3) = ( (x*x') \ (x*Yresid(1:end-1,:)') )';

    Yresid = Y - Eerr*est.tfperrcoef(:,1:8) ...
                 - bsxfun(@plus, est.tfp, translog_lnpred(est, Y, INPT, INPT2));
    for f = find(~cellfun('isempty', tfpX))
        est.tfpcoef{f} = tfpXXinv{f}*(tfpX{f}'*Yresid(:,f));
    end
end

em_alg2(@calc, sv, 'convg_checktranslog', 'TolRelX', .0005, 'savelocation', saveloc);

end
