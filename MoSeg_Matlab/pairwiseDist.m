function A = pairwiseDist(varargin)
% pairwiseDist compute pairwise distance between points
%
%   A = pairwiseDist(X) where X is NxP returns an NxN matrix of distances
%   between the P-dimensional data
%
%   A = pairwiseDist(X, 'PARAM1', value1, 'PARAM2', value2, ...)
%   specifies optional parameters. Parameters are:
%
%   'DistFun' - an anonymous function f(x1, x2) used to compute distance
%   between two points in X. Must return a scalar. Default is squared
%   euclidean distance. If X is an Nx1 struct array with, DistFun must be
%   defined for structs of the given type.
%
%   'Symmetric' - specifies whether the given DistFun is commutative. That
%   is, Dist(x1, x2) == Dist(x2, x1). If this property does not hold, set
%   'Symmetric' to 'false'. Default is 'true'
%
%   'UseParallel' - whether or not to use mutliple cores from the matlab
%   pool. Choices are 'always' or 'never'. Default is 'never'
%
%   'SparseOutput' - whether or not the returned matrix A should be sparse.
%   Choices are 'true' or 'false'. If the given 'DistFun' tends to return a lot
%   of zeros, this may be a desirable feature.

% default args
dfun = @(x1, x2) sum((x1-x2) .* (x1-x2));
use_par = false;
use_sparse = false;
sym = true;

% get actual args
X = varargin{1};

for arg = 2 : 2 : floor((length(varargin)-1)/2)*2+1
    switch(varargin{arg})
        case 'DistFun'
            dfun = varargin{arg+1};
        case 'UseParallel'
            switch(varargin{arg+1})
                case 'always'
                    use_par = true;
                case 'never'
                    use_par = false;
                otherwise
                    error('Allowable options for UseParallel are "always" or "never"');
            end
        case 'SparseOutput'
            switch(varargin{arg+1})
                case 'true'
                    use_sparse = true;
                case 'false'
                    use_sparse = false;
                otherwise
                    error('Allowable options for SparseOutput are "true" or "false"');
            end
        case 'Symmetric'
            switch(varargin{arg+1})
                case 'true'
                    sym = true;
                case 'false'
                    sym = false;
                otherwise
                    error('Allowable options for Symmetric are "true" or "false"');
            end
    end
end

N = size(X,1);
if(isstruct(X))
    N = length(X);
end

if(use_sparse)
    A = sparse(N,N);
else
    A = zeros(N,N);
end

if(use_par)
    parfor i=1:N*N
        [r, c] = ind2sub([N, N], i);
        if sym && r < c, continue; end
        if isstruct(X)
            A(i) = dfun(X(r), X(c));
        else
            A(i) = dfun(X(r,:), X(c,:));
        end
    end
else
    for i=1:N*N
        [r, c] = ind2sub([N, N], i);
        if sym && r < c, continue; end
        if isstruct(X)
            A(i) = dfun(X(r), X(c));
        else
            A(i) = dfun(X(r,:), X(c,:));
        end
    end
end

if sym
    for r=1:N
        for c=r+1:N
            A(r,c) = A(c,r);
        end
    end
end

end

%{
% unused helper function
function [r, c] = itorc(ind, N, symmetric)
if symmetric
    % index into diagonal matrix
    P = N*(N+1)/2;
    r = 1 + round(N - sqrt((P-ind+1)*2));
    c = ind - sum(N - (0:(r-2)));
else
    r = floor((ind-1) / N) + 1;
    c = ind - (N * (r-1));
end
end
%}
