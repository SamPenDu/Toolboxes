function [x z] = InvPsychFunc(F,y,xr)
%
% [x z] = InvPsychFunc(F,y,xr)
%
%   Inverts a cumulative Gaussian psychometric function F fitted with FitPsychFunc.
%       This is not a real "inversion" but a poor man's hack. It determines
%       the two data points nearest to the desired y value and returns its x.
%       The variable xr defines the range of x values to search in.
%       The second output z is the actual y value at this point.
%

s = (xr(2)-xr(1))/1e6;
X = xr(1) : s : xr(2);

% Calculate the function
Y = (0.5*(1 + erf((X-F.threshold(1))/(sqrt(2)*F.bandwidth(1))))) * F.amplitude + F.baseline;

% Minimal difference to point of interest 
D = abs(Y-y);
m = find(D==min(D));

% Find threshold
x = X(m);
z = Y(m);

% In asymptote?
if y >= max(Y)
    x = Inf;
    z = z(1);
elseif y <= min(Y)
    x = -Inf;
    z = z(1);
end
