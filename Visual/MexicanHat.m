function outputimg = MexicanHat(inputimg, sigma, lambda, xpos, ypos, contr)
%outputimg = MexicanHat(inputimg, sigma, lambda, xpos, ypos, [contr])
%
% Draws a difference-of-gaussians ("Mexican hat") into the input image.
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of larger Gaussian envelope
%   lambda :    Standard deviation of smaller Gaussian
%   xpos :      X pixel coordinate of the Gabor centre in the image 
%   ypos :      Y pixel coordinate of the Gabor centre in the image
%   contr :     Optional, defines the contrast of the Gabor between 0-1
%                   If this is a vector it defines the two contrasts separately.
%
% The function returns the new image containing the new Gaussian element.
%

% If contrast undefined it is 100%
if nargin < 5
    contr = [1 1];
end
if length(contr) == 1
    contr = [contr contr];
end

% Create output image
outputimg = inputimg;
dims = size(outputimg);

% Coordinates of all pixels of the Mexican hat relative to its centre
[X Y] = meshgrid(-4*sigma : 4*sigma, -4*sigma : 4*sigma);

% Luminance modulation at each pixel:
%  p = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%           Larger (negative) Gaussian                                               Smaller (positive) Gaussian                       
L = -(exp(-((X.^2)./(2*sigma.^2))-((Y.^2)./(2*sigma.^2))) * 0.5 * contr(1)) + (exp(-((X.^2)./(2*lambda.^2))-((Y.^2)./(2*lambda.^2))) * contr(2));

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
