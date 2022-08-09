function y = round_decs(x,d)
%y = round_decs(x,d)
%
% Rounds x to d decimals. This function is redundant because you can simply
% use round in the same way (included for backward compatability?)
%

f = 10^d;
y = round(x*f)/f;