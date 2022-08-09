function imgout = GaborRing(imgin, radius, lambda, xpos, ypos, contr, radfrq, ampl, orientation, phase)
%imgout = GaborRing(imgin, radius, lambda, xpos, ypos, [contr, radfrq, ampl, orientation, phase])
%
% Draws a ring with a Gabor profile (it doesn't consist of individual Gabors!)
%
% Parameters:
%   imgin :         Input image to draw on
%   radius :        Radius of the ring (in pixels)
%   lambda :        Standard deviation of Gaussian envelope & wavelength of carrier grating
%   xpos :          X pixel coordinate of the Ring centre in the image 
%   ypos :          Y pixel coordinate of the Ring centre in the image
%   contr :         Contrast of the Gabor function (default = 1)
% 
%  These two can be 2-element vectors. This means the first component is a cosine and the second a sine modulation:
%   radfrq :        Radial frequency of the wave modulating radius (default = 0)
%   ampl :          Amplitude of the wave modulating radius (default = 0)
%
%   orientation :   Orientation of the shape (phase of radial frequency function)
%   phase :         Phase of the Gabor function
%
% The function returns the new image.
%

if nargin < 6
    contr = 1;
    radfrq = 0;
    ampl = 1;
    orientation = 0;
    phase = 0;
elseif nargin < 7
    radfrq = 0;
    ampl = 1;
    orientation = 0;
    phase = 0;
elseif nargin < 8
    ampl = 1;
    orientation = 0;
    phase = 0;
elseif nargin < 9
    orientation = 0;
    phase = 0;
elseif nargin < 10
    phase = 0;
end

% Image parameters
width = size(imgin,1);
imgout = imgin;

% Convert orientation to radians
orientation = orientation / 180 * pi;

% Rho coordinate at each pixel
[x y] = meshgrid(1:width, 1:width);
x = x - xpos;
y = y - ypos;
if length(radfrq) == 1
    rho = sqrt(x.^2 + y.^2) + cos(atan2(y,x)*radfrq+orientation)*ampl;
else
    rho = sqrt(x.^2 + y.^2) + cos(atan2(y,x)*radfrq(1)+orientation)*ampl(1) + sin(atan2(y,x)*radfrq(2)+orientation)*ampl(2);
end

% Image is Rho passed to Gabor function
img =  exp(-((rho-radius).^2/(2*lambda.^2))) .* cosd((rho-radius)*(360/lambda/2)+phase) * contr/2; 
imgout = imgout + img;
