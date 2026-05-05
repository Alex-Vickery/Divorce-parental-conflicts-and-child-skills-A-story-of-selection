function [est,fval] = translog2LVLmle(Y, INPT1, INPT2, sv, f)
%-------------------------------------------------------------------------%
% translog2LVLmle.m
% Purpose:  Estimates translog production function parameters (TFP level,
%           returns to scale, input elasticities) via quasi-Newton MLE for
%           a single skill equation f.
% Arguments:
%   Y       - N x 1 residualised skill outcome
%   INPT1   - N x 27 translog input terms
%   INPT2   - N x 2 [conflicts, divorce] (not used directly; kept for API)
%   sv      - struct with starting values: lntfp, retscal, inptelas
%   f       - function index (1..8), selects relevant parameter blocks
% Returns:
%   est     - struct with updated lntfp, retscal, inptelas
%   fval    - negative log-likelihood at optimum
%-------------------------------------------------------------------------%

% translog
tfpEST = ~(~isfield(sv,'lntfp') || (sv.lntfp==0));
retscalEST = sv.retscal~=1;
inptelasEST = sv.inptelas~=0;
split_parms = +[tfpEST;
                retscalEST;
                inptelasEST];

function [ll,gr,b] = calclike(parms)

    parms = mat2cell(parms, split_parms, 1);

    b = struct('lntfp',0,'retscal',1,'inptelas',+inptelasEST);
    if tfpEST, b.lntfp = parms{1}; end
    if retscalEST, b.retscal = abs(parms{2}); end
    if nnz(inptelasEST)>1
        idx = [3:1:11;3:1:11;12:1:20;21:1:29];
        idx = repelem(idx,2,1);
        b.inptelas(inptelasEST) = [parms{idx(f,:)}];
    end
    if nnz(inptelasEST)==1
        b.inptelas(inptelasEST) = [parms{10}];
    end

    % translog
    lnI = INPT1*b.inptelas;
    retlnI = b.retscal*lnI;

    resid = Y - b.lntfp - retlnI;

    ll = -.5*sum(resid.^2);

    gr = arrayfun(@(n) zeros(n,1), split_parms, 'unif', 0);
    if tfpEST
        gr{1} = sum(resid);
    end
    if retscalEST
        gr{2} = (resid'*lnI);
    end
    if nnz(inptelasEST)>1
        temp = (INPT1' * (b.retscal * resid));
        idx = [1:1:9;1:1:9;10:1:18;19:1:27];
        idx = repelem(idx,2,1);
        for i = idx(f,1)+2:idx(f,9)+2
            gr{i} = temp(i - 2);
        end
    end
    if nnz(inptelasEST)==1
        gr{10} = (INPT1(:,8)' * (b.retscal * resid));
    end
    gr = cat(1,gr{:});

    ll = -ll;
    gr = -gr;
end

parms0 = cell(3,1);
if tfpEST, parms0{1} = sv.lntfp; end
if retscalEST, parms0{2} = sv.retscal; end
if nnz(inptelasEST)>1
    parms0{3} = nonzeros(sv.inptelas);
end
if nnz(inptelasEST)==1
    parms0{3} = nonzeros(sv.inptelas);
end
parms0 = cat(1,parms0{:});
o1 = optimoptions(@fminunc, 'Display', 'off', 'MaxIter', 1e4, 'MaxFunEvals', 1e6, ...
    'Algorithm', 'Quasi-newton', 'GradObj', 'on', 'DerivativeCheck', 'off', ...
    'FinDiffType', 'central', 'TolX', 1e-9, 'HessUpdate', 'bfgs');
[parms,fval] = fminunc(@calclike, parms0, o1);
[~,~,est] = calclike(parms);

end
