function lnpred = translog_lnpred(est, Y, INPT, INPT2)
%-------------------------------------------------------------------------%
% translog_lnpred.m
% Purpose:  Computes the deterministic translog component of log skill
%           production (returns-to-scale * weighted input index).
% Arguments:
%   est     - struct with fields retscal (1x8) and inptelas (27x8)
%   Y       - N x 8 skill outcomes (used only to get dimensions)
%   INPT    - N x 27 translog input terms
%   INPT2   - N x 2 (not used; kept for consistent API)
% Returns:
%   lnpred  - N x 8 predicted log-input component
%-------------------------------------------------------------------------%

[N,numF] = size(Y);

lnpred = zeros(N,numF);

for f = 1:numF
    if est.retscal(f) ~= 0
        % Translog
        lnI = INPT*est.inptelas(:,f);
    else
        lnI = 0;
    end
    lnpred(:,f) = est.retscal(f)*lnI;
end
