function [nrR nrP] = rem_redmat(R,P)
%
% Sets the redundant off-diagonal cells in correlation matrix R to zero and
% the corresponding p-values to 1. If P is undefined it replaces the ones
% included in the surviving R matrix with NaNs.
%

if nargin == 1
    P = NaN(size(R));
end

nrR = R; 
nrP = P;

rows = size(R,1);

for i = 1:rows
    nrR(i,1:i) = 0;
    nrP(i,1:i) = NaN;
end