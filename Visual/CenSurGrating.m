function outputimg = CenSurGrating(inputimg, sigma, theta, lambda, phase, xpos, ypos, contr)
%outputimg = CenSurGrating(inputimg, sigma, theta, lambda, phase, xpos, ypos, [contr])
%
% Draws a centre-surround grating with specified parameters into the input image.
% The central region up to 0.5*sigma will have orientation theta(1), 
% the surrounding region (minus a small gap) will have orientation theta(2).
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Radius of central & whole grating envelope 
%   theta :     Orientations of the carriers (0 deg = 3 o'clock, positive is counter-clockwise)
%   lambda :    Wavelength of the carriers (only one for both)
%   phase :     Phase of the carrier (cosine grating so 0 deg = light peak in middle)
%   xpos :      X pixel coordinate of the grating centre in the image 
%   ypos :      Y pixel coordinate of the grating centre in the image
%   contr :     Optional, defines the contrasts of the gratings between 0-1
%
% The function returns the new image containing the new grating.
% Angles and phases are passed in degrees and converted into radians internally.
%

% If contrast undefined it is 100%
if nargin < 8
    contr = [1 1];
end
if length(contr) == 1
    contr = [contr contr];
end

% Create output image
outputimg = inputimg;
dims = size(outputimg);

% Mathematical convention
theta = -(theta-90);

% Convert to radians
theta = pi * theta / 180; 
phase = pi * phase / 180;

% Coordinates of all pixels of the Gabor relative to its centre
[X Y] = meshgrid(-3*sigma(2) : 3*sigma(2), -3*sigma(2) : 3*sigma(2));
R = sqrt(X.^2 + Y.^2);
T = zeros(size(R));
T(R < sigma(1)) = theta(1);
T(R >= sigma(1)) = theta(2);
C = ones(size(R)) * contr(1)/2;
C(R > sigma(1) & R <= sigma(2)) = contr(2)/2;
C(R > sigma(1) & R < sigma(1)+4) = 0;
C(R > sigma(2)) = 0;

% Luminance modulation at each pixel
L = (cos(2*pi .* (cos(T).*X + sin(T).*Y) ./ lambda + phase)) .* C;

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
    

