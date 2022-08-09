function L = SineGrating(theta, lambda, phase, contr, width)
%img = SineGrating(theta, lambda, phase, contr, width);

% Convert to radians
phase = phase / 180 * pi;
% Coordinates of all pixels 
[X Y] = meshgrid(1:width, 1:width);
% Luminance modulation at each pixel
L = (cos(2*pi .* (sind(theta).*X + cosd(theta).*Y) ./ lambda + phase)) * 0.5 * contr;
L = 0.5 + L;
