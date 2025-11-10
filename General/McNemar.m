function [p, ChiSq] = McNemar(b, c)
%
% [p, ChiSq] = McNemar(b, c)
%
% Returns the p-value and associated Chi-squre value for the McNemar test:
% Input variables are numbers of data points defined as follows:
%   b:  Condition 1 positive, condition 2 negative
%   c:  Condition 1 negative, condition 2 positive
%
% https://en.wikipedia.org/wiki/McNemar%27s_test
%
% 06/10/2025 - Written (DSS)
%

% Calculate Chi-square
ChiSq = (b-c)^2 / (b+c);

% Calculate p=value
p = 1 - chi2cdf(ChiSq, 1);

