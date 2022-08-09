function [b ci] = bslinfit(X,Y,bn)
%
% [b ci] = bslinfit(X,Y,bn)
%
% Bootstrap a linear regression
%

if nargin < 3
    bn = 10000;
end

n = size(Y,1);
b = polyfit(X, Y, 1)';

bs = []; 
for i = 1:bn 
    s = ceil(rand(n,1)*n); 
    bc = polyfit(X(s), Y(s), 1); 
    bs = [bs; bc]; 
end

% Determine confidence limits
alpha = 0.05;
[s x] = sort(bs(:,1));
bs = bs(x,:);
low = round(alpha*bn/2);
high = round(bn*(1-alpha/2));
ci = [bs(low,1) bs(high,1); bs(low,2) bs(high,2)];
