function t = t_value(p, v)
%Returns the t-value associated with p-value p and degrees of freedom v.

t = tinv(1 - p/2, v);