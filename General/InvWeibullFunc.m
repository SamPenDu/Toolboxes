function x = InvWeibullFunc(F,y)
%
% x = InvWeibullFunc(F,y)
%
%   Inverts a cumulative Weibull psychometric function F fitted with FitWeibullFunc.
%       Returns the x value producing the desired y value.
%

wy = (y-F.baseline) / F.amplitude;
x = wblinv(wy, F.threshold, F.bandwidth);