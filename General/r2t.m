function t = r2t(r,n)
%t = r2t(r,n) 
%
% Converts the correlation coefficient r for n subjects into t.
%

t = sign(r) .* (abs(r) .* sqrt((n-2) ./ (1-r.^2)));
