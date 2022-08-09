function z = nanzscore(m)
%
% z-standardizes matrix m but ignores NaNs.
%

n = size(m,1);
z = (m-repmat(nanmean(m,1),n,1)) ./ repmat(nanstd(m),n,1);