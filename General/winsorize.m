function tX = winsorize(X,t)
%
% tX = winsorize(X, [t=10])
%
% Winsorizes the sample in X, i.e. the t most extreme percentiles of the 
% observations in X are set to the maximum and minimum, respectively, of the 
% remaining values. By default t = 10; 
%

if nargin < 2
    t = 10;
end

% Percentiles to be trimmed
p = prctile(X, [t 100-t]);

% Ensure it's a column
if size(p,1) == 1
    p = p';
end

% Set extremes to maximum & minimum
tX = X; nX = X;
for c = 1:size(p,2)
    % Determine minimum & maximum of remaining values
    nX(X(:,c) < p(1,c) | X(:,c) > p(2,c), c) = NaN;
    rmin = nanmin(nX(:,c));
    rmax = nanmax(nX(:,c));
    % Set extremes to minimum & maximum, respectively
    tX(X(:,c) < p(1,c), c) = rmin;
    tX(X(:,c) > p(2,c), c) = rmax;
end

