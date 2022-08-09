function [theta rho] = MeanDir(deg, mag) 
%[theta rho] = MeanDir(deg, [mag])
%
% Calculates the mean direction and magnitude by vectorial addition.
%
% Parameters:
%   deg :    Vector of orientation values (in degrees)
%   mag :    Vector of normalized magnitudes (optional)
%
% Returns the direction (0-360 degrees) and the bias magnitude.

if nargin == 1 || isempty(mag)
    mag = ones(size(deg));
end

deg = deg / 180 * pi;

[x y] = pol2cart(deg, mag);
x = mean(x);
y = mean(y);

[theta rho] = cart2pol(x, y);
theta = theta / pi * 180;
