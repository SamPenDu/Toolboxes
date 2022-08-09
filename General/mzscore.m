function z = mzscore(m)
%
% Standardizes matrix m by the median absolute deviation.
%

n = size(m,1);
z = (m-repmat(nanmedian(m), n, 1)) ./ repmat(mad(m,1) * 1.4826, n, 1);