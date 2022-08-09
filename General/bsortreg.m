function [Ms Ci] = bsortreg(A, B, n)
%[Ms Ci] = bsortreg(A, B, n) 
%
% Bootstraps confidence interval for orthogonal regression between A and B 
% with n (default = 10,000) simulated pairings (randomized with replacement).
%
%   Ms is a vector of coefficients 
%   Ci is the confidence interval
%

if nargin < 3
    n = 10000;
end

Ms = []; 

for i = 1:n
    x = ceil(rand(size(A,1),1)*size(A,1));
    As = A(x);
    Bs = B(x);
    [F R] = ortregpca(As,Bs);
    Ms = [Ms; F];
end

% Determine confidence limits
Ci = prctile(Ms, [2.5 97.5]);
