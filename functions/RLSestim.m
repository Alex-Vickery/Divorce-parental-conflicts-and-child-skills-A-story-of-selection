function [b,R,r] = RLSestim(XX, XY, b, R, r)
%-------------------------------------------------------------------------%
% RLSestim.m
% Purpose:  Constructs the restriction matrices (R, r) for random
%           least squares from a vector of starting values b. When called
%           with empty XX (as in translog.m), returns only R and r without
%           solving the regression.
% Arguments:
%   XX  - X'X matrix (pass [] to only construct restriction matrices)
%   XY  - X'Y vector  (pass [] to only construct restriction matrices)
%   b   - parameter vector specifying restrictions (values in {0,1,-1}
%         are treated as equality constraints; equal non-zero values imply
%         equality between coefficients)
%   R, r - (optional) pre-constructed restriction matrices
% Returns:
%   b   - estimated parameter vector (or input b if XX is empty)
%   R   - restriction matrix
%   r   - restriction vector
%-------------------------------------------------------------------------%

if ~isempty(b)

    np = numel(b);

    bNORM = ismember(b,[0 1 -1]);
    R = full(sparse(1:nnz(bNORM),find(bNORM),1,nnz(bNORM),np));
    r = b(bNORM);

    univals = unique(b(~bNORM))';
    i = size(R,1)+1;
    for u = univals
        f = find(b==u);
        for j = 2:numel(f)
            R(i,f(1)) = 1;
            R(i,f(j)) = -1;
            r(i) = 0;
            i = i + 1;
        end
    end

end

if isempty(XX), return; end

nr = size(R,1);
