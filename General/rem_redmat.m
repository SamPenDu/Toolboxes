function [nrR, nrP] = rem_redmat(R, P, Upper)
%
% Sets the redundant off-diagonal cells in correlation matrix R to zero and
% the corresponding p-values to 1. If P is undefined it replaces the ones
% included in the surviving R matrix with NaNs.
%
% The optional third input Upper defines if the remaining cells are in the
% top-right (default=true) or bottom-left (false) triangle.
%

if nargin == 1
    P = NaN(size(R));
end
if nargin < 3
    Upper = true;
end

nrR = R; 
nrP = P;

rows = size(R,1);

if Upper
    % Upper-right triangle
    for i = 1:rows
        nrR(i,1:i) = 0;
        nrP(i,1:i) = NaN;
    end
else 
    % Lower-left triangle
    for i = 1:rows
        nrR(i,i:end) = 0;
        nrP(i,i:end) = NaN;
    end
end