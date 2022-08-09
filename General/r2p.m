function p = r2p(r,n)
%p = r2p(r,n) 
%
% Returns the p-value p for correlation coefficient r with n subjects.
%

p = p_value(r2t(r,n), n-2);