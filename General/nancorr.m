function [R, P] = nancorr(X, Method)
%
% [R, P] = nancorr(X, Method)
%
% Calculates the column-wise correlation matrix of matrix X.
% It effectively does what corr(X) would do but ignores NaNs.
% The optional input Method is the test name as in corr.
%
% Returns matrix of correlation coefficients & p-values.
%

if nargin < 2
    Method = 'pearson';
end

R = NaN(size(X,2), size(X,2)); % Correlation matrix
P = NaN(size(X,2), size(X,2)); % Significance values

% Loop thru rows
for i = 1:size(X,2)
    % Loop thru columns
    for j = 1:size(X,2)
        [r,p] = corr(rem_nan([X(:,i) X(:,j)]), 'type', Method); % Correlation
        % Store for output
        R(i,j) = r(1,2);
        P(i,j) = p(1,2);
    end
end
