function mu = MeanCorr(Rs)
% mu = MeanCorr(Rs)
%
% Returns the mean of a vector of correlation coefficients Rs. 
% It first z-transforms the correlation coefficients and then transforms
% the mean back into a correlation coefficient.
%

Zs = atanh(Rs);
mu = tanh(nanmean(Zs));