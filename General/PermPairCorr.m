function [Rmed, Rs] = PermPairCorr(XY, j, CorrType)
%
% [Rmed, Rs] = PermPairCorr(XY, [j=10000, CorrType='p'])
%
% Runs j permutations of a correlation analysis where the two variables are 
%  assigned arbitrarily. XY is a two column matrix where each row is a pair 
%  of observations. On each permutation the elements in each row are shuffled 
%  between columns and a new correlation between columns is computed. 
%
% The optional input j defines the number of permutations. Defaults to 10000. 
%
% The optional input CorrType defines the type of correlation (see corr.m) 
%  and this defaults to 'p' for a standard Pearson correlation.
%
% Returns the median of correlation coefficients across permutations Rmed
%  and the vector of the j correlation coefficients Rs.
%

if nargin == 1
    j = 10000;
end
if nargin <= 2
    CorrType = 'p';
end
    
Rs = []; % Correlation coefficients
n = size(XY,1); % Sample size

% Loop thru permutations
for i = 1:j   
    sXY = []; % Shuffled matrix
    % Loop thru observations
    for k = 1:n
        if rand > 0.5 % Swap columns in this row?
            sXY = [sXY; XY(k,[2 1])]; % Swap columns
        else
            sXY = [sXY; XY(k,[1 2])]; % Don't swap columns        
        end
    end
    Rs = [Rs; corr(sXY(:,1), sXY(:,2), 'type', CorrType)]; % Add correlation to vector
end

Rmed = median(Rs); % Median of correlations

