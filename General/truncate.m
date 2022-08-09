function tX = truncate(X,t)
%
% tX = truncate(X, [t=10])
%
% Truncates the sample in X, i.e. the t most extreme percentiles of the 
% observations in X are set to NaN. By default t = 10; 
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

% Set outliers to NaN
tX = X;
for c = 1:size(p,2)
    tX(tX(:,c)<p(1,c) | tX(:,c)>p(2,c), c) = NaN;
end

