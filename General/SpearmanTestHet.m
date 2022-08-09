function [p r ci ps] = SpearmanTestHet(x,y,b)
% 
% [p r ci ps] = SpearmanTestHet(x,y,[b])
%
% Use Spearman's Rho to test two samples for heteroscedasticity.
% The function returns a p-value and in the second argument the rho.
% The third argument contains the bootstrapped 95% confidence interval 
% and the p-value from that bootstrap distribution (only if the number of 
% bootstrap samples, b, was defined).
%
% The test works by first obtaining the residuals for a linear fit, then
% calculating Spearman's rho for the squared residuals and the predictor.
%

if nargin < 3
    b = 0;
end

s = regstats(y, x, 'linear', 'r');
[r p] = corr(x, s.r.^2, 'type', 'spearman');
if b > 0
    [rs ci ps] = bscorr(x, s.r.^2, b, 'spearman');
else
    ci = [NaN NaN];
    ps = Inf;
end