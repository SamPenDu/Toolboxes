function outputimg = PolarGabor(inputimg, sigma, theta, lambda, phase, xpos, ypos, contr, modax)
%outputimg = PolarGabor(inputimg, sigma, theta, lambda, phase, xpos, ypos, [contr, modax])
%
% Draws a non-cartesian Gabor with specified parameters into the input image.
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of Gaussian envelope
%   theta :     Orientation of the carrier (0 deg = 3 o'clock, positive is counter-clockwise)
%   lambda :    Wavelength of the carrier (in degrees if radial pattern)
%   phase :     Phase of the carrier (cosine grating so 0 deg = light peak in middle)
%   xpos :      X pixel coordinate of the Gabor centre in the image 
%   ypos :      Y pixel coordinate of the Gabor centre in the image
%   contr :     Optional, defines the contrast of the Gabor between 0-1
%   modax :     Optional, modulation axis (default = '*')
%                   '*' = Radial pattern (modulated along polar angle)
%                   'o' = Concentric pattern (modulated along radius)
%
% The function returns the new image containing the new Gabor element.
% Angles and phases are passed in degrees and converted into radians internally.
%

% If contrast undefined it is 100%
if nargin < 8
    contr = 1;
    modax = '*';
elseif nargin < 9
    modax = '*';
end

% Create output image
outputimg = inputimg;
dims = size(outputimg);

% Mathematical convention
theta = -(theta-90);

% Convert to radians
theta = pi * theta / 180; 
phase = pi * phase / 180;
if modax == '*'
    lambda = pi * lambda / 180;
end

% Coordinates of all pixels of the Gabor relative to its centre
[X Y] = meshgrid(-3*sigma : 3*sigma, -3*sigma : 3*sigma);
T = atan2(Y,X);
R = sqrt(X .^ 2 + Y .^ 2);

% Polar coordinates of all pixels of the Gabor relative to its centre

% Luminance modulation at each pixel:
% Gabor function = oriented sinusoidal carrier grating within a Gaussian envelope.
%  p = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%       Gaussian                                 Sinusoid    Wavelength & Phase                                        
if modax == '*'
    L = exp(-((X.^2)./(2*sigma.^2))-((Y.^2)./(2*sigma.^2))) .* cos(T .* (2*pi/lambda) + phase) * contr/2;
elseif modax == 'o'
    L = exp(-((X.^2)./(2*sigma.^2))-((Y.^2)./(2*sigma.^2))) .* cos(R .* (0.75*sigma/lambda) + phase) * contr/2;
else
    error('Invalid modulation axis!');
end

% Determine pixel coordinates in the image
X = X + xpos;
Y = Y + ypos;

% Remove pixels outside the image
xrng = X(1,:) > 0 & X(1,:) <= dims(2);
yrng = Y(:,1) > 0 & Y(:,1) <= dims(1);
% X and Y are reversed because image is a MatLab Row x Col matrix!
X = X(yrng,xrng);
Y = Y(yrng,xrng);
L = L(yrng,xrng);

% Add the modulation of the pixels to the background intensity.
% X and Y are reversed because image is a MatLab Row x Col matrix!
outputimg(Y(:,1), X(1,:)) = outputimg(Y(:,1), X(1,:)) + L;
    

