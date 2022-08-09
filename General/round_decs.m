function y = round_decs(x,d)
%y = round_decs(x,d)
%
% Rounds x to d decimals 
%
% NOTE: This function is redundant & simply calls round(x,d). It is only
% included to ensure backwards compatibility with code I no longer use...
%

y = round(x,d);