function op = convg_checktranslog(est)
%-------------------------------------------------------------------------%
% convg_checktranslog.m
% Purpose:  Extracts the parameter vector used for convergence checking
%           in the EM algorithm (called by em_alg2).
% Arguments:
%   est   - 1x2 array of consecutive parameter structs [current, previous]
% Returns:
%   op    - 292 x 2 matrix of parameter values for the two iterations
%-------------------------------------------------------------------------%

op = zeros(292,2);

for i = 1:2

    op(:,i) = [est(i).retscal(:);
                est(i).inptelas(:);
                est(i).var(:);
                est(i).bta(:);
                est(i).eta(:);
                est(i).alpha(:)];

end
