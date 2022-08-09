function r = p2r(p,n)
%r = p2r(p,n) 
%
% Returns the correlation coefficient r for p-value p with n subjects.
%

r = t2r(t_value(p,n-2),n);