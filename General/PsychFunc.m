function y = PsychFunc(x,F)
%
% y = PsychFunc(x,F)
%
%   Returns the y for F(x)
%

y = (0.5*(1 + erf((x-F.threshold(1))/(sqrt(2)*F.bandwidth(1))))) * F.amplitude + F.baseline;
