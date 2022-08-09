function [p f df] = gqtest(X,Y,k)
%
% [p f df] = gqtest(X,Y,k)
%
% Goldfeld-Quandt test of a two-sample data set for heteroscedasticity.
% Doesn't seem to work very well so not using it.
%

n = length(X);
if nargin < 3
    k = ceil(n/3);
end

% Squared residuals
Rs = regstats(Y, X, 'linear',{'r'});
Rs = Rs.r;
Rs = Rs .^ 2;

% Sorted by X
[X x] = sort(X);
Rs = Rs(x);

% Split data
A = Rs(1:k);
B = Rs(end-k:end);

% Perform F-test
f = mean(A) / mean(B);
df = [n-k-2-2 2];
p = 1-fcdf(f, df(1), df(2));
