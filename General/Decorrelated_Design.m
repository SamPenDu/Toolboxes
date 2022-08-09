function [X R] = Decorrelated_Design(T)
%
% [X R] = Decorrelated_Design(T)
%
% Creates a decorrelated (|R|<0.1) design matrix with the 
% same number of columns as the row vector T. The should
% be a vector containing the variables to be counterbalanced.
%
% Output X is the decorrelated design matrix.
% R contains the correlation matrix for X.
%

n = length(T); % Number of columns
T = T(randperm(n)); % Shuffle input vector

% Shift sequence by one row within each column
X=[]; 
for i=0:n-1
    X=[X; T(i+1:end) T(1:i)]; 
end

R = corr(X); % Correlation matrix