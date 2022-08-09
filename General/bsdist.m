function Y = bsdist(X, j)
%
% Y = bsdist(X, [j=10000])
%
% Bootstraps the mean of a vector X.
%   j defines the number of bootstraps (default=10,000)
%

if nargin < 2
    j = 10000;
end

rows = size(X,1);
Y = [];
for s = 1:j
    n = ceil(rand(rows,1)*rows);
    y = X(n);
    if sm
        y = y + randn(rows,1);
    end
    Y = [Y; nanmean(y)];
end
