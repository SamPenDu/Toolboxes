function e = sem(x, dim)
% Calculates standard error of the mean for x.
% By default, this is across rows in x. For columns or other dimensions,
% define dim > 1.

if nargin < 2
    dim = 1;
end

e = sqrt(nanvar(x, 0, dim) ./ sum(~isnan(x), dim));
