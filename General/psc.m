function Y = psc(X)
%
% Y = psc(X)
%
% Normalises columns in matrix X to be in units of percent signal change.
% This is an equivalent operation to Matlab's zscore function.
%
% The optional input argument MeanCorr toggles whether to apply mean
% correction.
%
% 05/10/2022 - It was written (DSS)
%

n = size(X,1); % Number of data rows
M = repmat(nanmean(X), n, 1); % Mean replicated to same size matrix as X
Y = (X-M)./M * 100; % Percent signal change normalisation