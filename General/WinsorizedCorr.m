function [r p W] = WinsorizedCorr(X, Y, cortyp, gamma)
%
%[r p W] = WinsorizedCorr(X, Y, [cortyp='s', gamma=0.2])
%
% Winsorizes correlation of the paired data sample [X,Y].
% The proportion of winsorized samples on each side is given by gamma. 
% r and p are the correlation coefficient and p-value, respectively.
% W contains the Winsorized data samples.
%

if nargin < 3
    cortyp = 's';
    gamma = 0.2;
elseif nargin < 4
    gamma = 0.2;
end

if lower(cortyp) == 'p'
    cortyp = 'pearson';
elseif lower(cortyp) == 's'
    cortyp = 'spearman';
elseif lower(cortyp) == 'k'
    cortyp = 'kendall';
end

% Sort data 
sX = sort(X);
sY = sort(Y);

% Determine limits etc
n = size(X,1);
g = floor(n*gamma);
lo = g+1;
hi = n-g;
h = n - 2*g;

% Winsorizing
wX = X;
wX(wX < sX(lo)) = sX(lo);
wX(wX > sX(hi)) = sX(hi);
wY = Y;
wY(wY < sY(lo)) = sY(lo);
wY(wY > sY(hi)) = sY(hi);

% Correlation
r = corr(wX, wY, 'type', cortyp);
t = r * sqrt((n-2) / (1-r.^2));
p = p_value(t, h);

W = [wX wY];