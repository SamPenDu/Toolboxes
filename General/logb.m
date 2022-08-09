function y = logb(x, b)
%Returns the base b logarithm of x (only for b > 1).

y = log(x) ./ log(b);