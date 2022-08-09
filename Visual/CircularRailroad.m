function img = CircularRailroad(radius, sigma, lambda, spiral, phase, width, contr)
%img = CircularRailroad(radius, sigma, lambda, spiral, phase, width, [contr])
%
% Draws a circular railroad stimulus.
%
% Parameters:
%   radius :    Radius of the circle (in pixels)
%   sigma :     Space constant of Gaussian envelope (smaller is wider)
%   lambda :    Wavelength of the sinusoid
%   spiral :    Spiral factor (0 = Radial, Inf = Concentric)
%   phase :     Phase of the sinusoid
%   width :     Image width in pixels
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

%% Grating
% Parameters for all pixels
[X Y] = meshgrid(-width/2:width/2-1, -width/2:width/2-1);
[T R] = cart2pol(X,Y);
T = T / pi * 180;
% Luminance modulation at each pixel
if isinf(abs(spiral))
    % Concentric grating
    G = 0.5 * sind(R * (360/lambda) + phase);
else    
    % Spiral grating
    G = 0.5 * sind(T * (360/lambda) + R*spiral + phase);
end

%% Rail track mask
% Parameters for all pixels
[X Y] = meshgrid(-width/2:width/2-1, -width/2:width/2-1);
[T R] = cart2pol(X,Y);
R = R - radius;
% Masking of grating 
M = exp(-((R./sqrt(2)*sigma).^2)) * contr(1);

%% Contrast step
% Parameters for all pixels
[X Y] = meshgrid(-width/4:width*3/4-1, -width/2:width/2-1);
% Masking of grating 
M = M + exp(-((X./sqrt(2)*sigma).^2)-((Y./sqrt(2)*sigma).^2)) * contr(2);

%% Image matrix
img = 0.5 + G .* M;


