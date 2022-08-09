function r = t2r(t,n)
%r = t2r(t,n) 
%
% Converts the t-value for n subjects into a correlation coefficient r.
%

r = sign(t) .* (abs(t) ./ sqrt(n - 2 + t.^2));
