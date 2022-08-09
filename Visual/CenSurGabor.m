function outputimg = CenSurGabor(inputimg, sigma, theta, lambda, phase, xpos, ypos, contr)
%outputimg = CenSurGabor(inputimg, sigma, theta, lambda, phase, xpos, ypos, [contr])
%
% Draws a centre-surround Gabor with specified parameters into the input image.
% The central region up to 0.8*sigma will have orientation theta(1), 
% the surrounding region (minus a small gap) will have orientation theta(2).
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of Gaussian envelope
%   theta :     Orientations of the carrier (0 deg = 3 o'clock, positive is counter-clockwise)
%   lambda :    Wavelength of the carrier
%   phase :     Phase of the carrier (cosine grating so 0 deg = light peak in middle)
%   xpos :      X pixel coordinate of the Gabor centre in the image 
%   ypos :      Y pixel coordinate of the Gabor centre in the image
%   contr :     Optional, defines the contrast of the Gabor between 0-1
%
% The function returns the new image containing the new Gabor element.
% Angles and phases are passed in degrees and converted into radians internally.
%

% If contrast undefined it is 100%
if nargin < 8
    contr = 1;
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
[X Y] = meshgrid(-3*sigma : 3*sigma, -3*sigma : 3*sigma);
R = sqrt(X.^2 + Y.^2);
T = zeros(size(R));
T(R < 0.8*sigma) = theta(1);
T(R >= 0.8*sigma) = theta(2);
C = ones(size(R)) * contr/2;
C(R > sigma*0.7 & R < sigma*0.9) = 0;

% Luminance modulation at each pixel:
% Gabor function = oriented sinusoidal carrier grating within a Gaussian envelope.
%  L = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%           Gaussian                                        Sinusoid    Carrier theta              Wavelength & Phase                                        
L = exp(-((X.^2)./(2*sigma.^2))-((Y.^2)./(2*sigma.^2))) .* (cos(2*pi .* (cos(T).*X + sin(T).*Y) ./ lambda + phase)) .* C;

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
    

