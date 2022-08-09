function p = p_value(t, v)
%Returns the p-value associated with t-value t and degrees of freedom v.

t = abs(t);
p = 2 * (1 - tcdf(t, v));