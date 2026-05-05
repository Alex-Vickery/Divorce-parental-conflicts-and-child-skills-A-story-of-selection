function [est,output] = em_alg2(EMstep, sv, convgfun, varargin)
%-------------------------------------------------------------------------%
% em_alg2.m
% Purpose:  Generic EM algorithm driver. Iterates EMstep until convergence
%           criteria are met, optionally saving checkpoints after each
%           iteration.
% Arguments:
%   EMstep    - function handle: [est, ll] = EMstep(est)
%   sv        - starting values struct
%   convgfun  - name of convergence-checking function (string)
%   varargin  - name-value pairs for EMopt fields:
%               'maxIter', 'minIter', 'TolX', 'TolRelX', 'TolFun',
%               'TolRelFun', 'printIter', 'savelocation'
% Returns:
%   est       - converged parameter struct
%   output    - struct with convergence diagnostics
%-------------------------------------------------------------------------%

EMopt = struct(...
    'maxIter',1e6,...
    'minIter',1,...
    'TolX',1e-4,...
    'TolRelX',0,...
    'TolFun',1e-3,...
    'TolRelFun',0,...
    'printIter',1,...
    'savelocation',[]);

while ~isempty(varargin)
    switch varargin{1}
        case fieldnames(EMopt)'
            EMopt.(varargin{1}) = varargin{2};
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
    varargin(1:2) = [];
end

abch = @(x) x(:,1)-x(:,2);
rech = @(x) (x(:,1)-x(:,2))./(x(:,2)+eps);
pach = @(x) (abs(x(:,2))<.01).*abch(x) + (abs(x(:,2))>=.01).*rech(x);

est = sv;
oll = -inf;

tic
for m = 1:EMopt.maxIter

    est0 = est;

    [est,ll] = EMstep(est);

    op = feval(convgfun,[est est0]);

    output = struct('Iterations',m,...
                    'LogLike',ll,...
                    'ChangeInLogLike',ll-oll,...
                    'ChangeInParms',norm(abch(op),inf),...
                    'PercentChangeInParms',norm(pach(op),inf),...
                    'Minutes',toc/60);

    HasConverged = any([(norm(abch(op),inf)<EMopt.TolX)
            (norm(pach(op),inf)<EMopt.TolRelX)
            (norm(ll-oll,inf)<EMopt.TolFun)
            (norm((ll-oll)/oll,inf)<EMopt.TolRelFun)]) && m>=EMopt.minIter;

    if (m==1) || (rem(m,EMopt.printIter)==0) || HasConverged
        fprintf('%d \t',m)
        fprintf('%8.4f \t',ll)
        fprintf('%8.4f \t',(ll-oll))
        fprintf('%8.6f \t',(ll-oll)/abs(oll))
        fprintf('%8.6f \t',norm(abch(op),inf))
        fprintf('%8.4f \t',norm(pach(op),inf))
        fprintf('%8.0f \n',toc)
    end
    if ~isempty(EMopt.savelocation)
        save(EMopt.savelocation,'est','output')
    end

    if HasConverged, break; end

    oll = ll;

end

end
