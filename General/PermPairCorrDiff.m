function [ci,Ds] = PermPairCorrDiff(XY1, XY2, j, CorrType)
%
% [ci,Ds] = PermPairCorrDiff(XY1, XY2, [j=10000, CorrType='p'])
%
% Runs j permutations of a correlation difference analysis where the two 
%  variables are assigned arbitrarily. XY1 and XY2 are two column matrices 
%  where each row is a pair of observations. On each permutation entries 
%  in each row are shuffled between columns and a new correlation between 
%  columns is computed using PermPairCorr. 
%
% The optional input j defines the number of permutations. Defaults to 10000. 
%
% The optional input CorrType defines the type of correlation (see corr.m) 
%  and this defaults to 'p' for a standard Pearson correlation.
%
% The function plots the distribution of the two correlation tests. It also
%  returns the 95% confidence interval ci of the differences between them 
%  and the distribution of differences Ds itself.
%

if nargin == 2
    j = 10000;
end
if nargin <= 3
    CorrType = 'p';
end
    
[~,Rs1] = PermPairCorr(XY1, j, CorrType); % Correlation for XY1
[~,Rs2] = PermPairCorr(XY2, j, CorrType); % Correlation for XY2

% Output arguments
Ds = Rs1 - Rs2;
ci = prctile(Ds, [2.5 97.5]);

% Plot distributions
cateye(Ds,1,[0 0 0]);
ylabel('\Delta_r');
