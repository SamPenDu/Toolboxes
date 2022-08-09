function [Rs Ci Ps] = bscorr(A, B, n, cortyp, err)
%[Rs Ci Ps] = bscorr(A, B, [n = 10000], [cortyp = 's'], [err]) 
%
% Bootstraps confidence interval for correlation between A and B with
% n (default = 10,000) simulated pairings (randomized with replacement).
%
% The optional cortyp is the type of correlation. 
%
% The optional err contains a vector of errors for a bootstrap weighted by the errors.
%   If this has one column, equal error is applied to both variables.  
%
% Rs is a vector of correlation coefficients. 
% Ci is the confidence interval (should not overlap 0 if real correlation).
% Ps is the proportion of coefficients with opposite sign than the median.
%

X = rem_nan([A B]);
A = X(:,1); 
B = X(:,2);

if nargin < 3
    n = 10000;
    cortyp = 's';
    err = zeros(size(A,1),2);
elseif nargin < 4
    cortyp = 's';
    err = zeros(size(A,1),2);
elseif nargin < 5
    err = zeros(size(A,1),2);
end

if isempty(err)
    err = zeros(size(A,1),2);
end   
    
if size(err,2) == 1
    err = [err zeros(size(A,1),1)];
end

if lower(cortyp) == 'p'
    cortyp = 'pearson';
elseif lower(cortyp) == 's'
    cortyp = 'spearman';
elseif lower(cortyp) == 'k'
    cortyp = 'kendall';
end

Rs = [];

for i = 1:n
    x = ceil(rand(size(A,1),1)*size(A,1));
    As = A(x)+randn(size(A,1),1).*err(x,1);
    Bs = B(x)+randn(size(A,1),1).*err(x,2);
    if cortyp(1) == 'w'
        Rs = [Rs; pbcorr(As,Bs)];
    elseif cortyp(1) == '3'
        Rs = [Rs; Shepherd(As,Bs,1000)];
    else
        Rs = [Rs; corr(As,Bs,'type',cortyp)];
    end
end

Ci = prctile(Rs, [2.5 97.5]);

% P-value
mR = median(Rs);
Ps = mean(sign(mR) * Rs <= 0);