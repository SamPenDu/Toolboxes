function img = PolarChecker(lambda, theta, width)
%img = PolarChecker(lambda, theta, width)
%
% Draws a circular railroad stimulus.
%
% Parameters:
%   lambda :    Wavelength of the sinusoid
%   theta :     Orientation of the sinusoid
%   width :     Image width in pixels
%
% The function returns the new image.
%

%% Grating
% Parameters for all pixels
[X Y] = meshgrid(-width/2:width/2-1, -width/2:width/2-1);
[T R] = cart2pol(X,Y);
% Luminance modulation at each pixel
G = sind((R+theta) .* lambda) + cos((T+(theta/180*pi)) .* lambda);

%% Image matrix
img = 0.5 + G;

