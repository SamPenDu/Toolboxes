function img = StraightRailroad(sigma, lambda, theta, phase, xwid, ywid, contr)
%img = StraightRailroad(sigma, lambda, theta, phase, , xwid, ywid, [contr])
%
% Draws a straight railroad stimulus.
%
% Parameters:
%   sigma :     Standard deviation of Gaussian envelope
%   lambda :    Wavelength of the sinusoid
%   theta :     Orientation of the sinusoid
%   phase :     Phase of the sinusoid
%   xwid :      X width in pixels
%   ywid :      Y width in pixels
%   contr :     Optional, 1x2 vector of contrasts (0-1)
%                   (1) the contrast of the grating
%                   (2) the added(!) contrast of the tip
%                       Default is [.5 .5] so the railroad is at 50% 
%                       and the tip is at 100% contrast
%
% The function returns the new image.
%

% If contrast undefined it is 100%
if nargin < 7
    contr = [.5 .5];
end

%% Rail track
% Parameters for all pixels
[X Y] = meshgrid([-xwid/4:-1 zeros(1,xwid/2) 1:xwid/4], -ywid/2:ywid/2-1);
% Masking of grating 
M = exp(-((X./sqrt(2)*sigma).^2)-((Y./sqrt(2)*sigma).^2)) * contr(1);

%% Contrast step
% Parameters for all pixels
[X Y] = meshgrid(-xwid/4:xwid*3/4-1, -ywid/2:ywid/2-1);
% Masking of grating 
M = M + exp(-((X./sqrt(2)*sigma).^2)-((Y./sqrt(2)*sigma).^2)) * contr(2);

%% Grating
% Convert to radians
theta = theta / 180 * pi;
phase = phase / 180 * pi;
% Coordinates of all pixels 
[X Y] = meshgrid(1:xwid, 1:ywid);
% Luminance modulation at each pixel
G = (cos(2*pi .* (sin(theta).*X + cos(theta).*Y) ./ lambda + phase)) * 0.5;

%% Image matrix
img = 0.5 + M .* G;


