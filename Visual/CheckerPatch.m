function outimg = CheckerPatch(img, sigma, checks, xpos, ypos, contr)
%outimg = CheckerPatch(img, sigma, checks, xpos, ypos, contr)
%
% Draws a checker patch with specified parameters into the input image.
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of Gaussian envelope
%   checks :    Width of a checker cell
%   xpos :      X pixel coordinate of the centre in the image 
%   ypos :      Y pixel coordinate of the centre in the image
%   contrs :    Contrast of the checkerboard (optional)
%
% The function returns the image with the new patch.
%

if nargin < 6
    contr = 1;
end

% Create output image
outimg = img;
dims = size(img);

% Coordinates of all pixels of the Gaussian relative to its centre
[X Y] = meshgrid(-3*sigma : 3*sigma, -3*sigma : 3*sigma);

% Checkerboard
Checkerboard = zeros(size(X));
Checkerboard(find(mod(floor(X./checks),2)==0 & mod(floor(Y./checks),2)==1)) = +1;
Checkerboard(find(mod(floor(X./checks),2)==1 & mod(floor(Y./checks),2)==0)) = +1;
Checkerboard(find(mod(floor(X./checks),2)==1 & mod(floor(Y./checks),2)==1)) = -1;
Checkerboard(find(mod(floor(X./checks),2)==0 & mod(floor(Y./checks),2)==0)) = -1;

% Luminance modulation at each pixel:
%  p = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%           Gaussian                         Checkerboard                                     
L = exp(-(X.^2)./(2*sigma.^2)-(Y.^2)./(2*sigma.^2)) .* Checkerboard * contr/2;

% Determine pixel coordinates in the image
X = X + xpos;
Y = Y + ypos;

% Add the modulation of the pixels to the background intensity.
% X and Y are reversed because image is a MatLab Row x Col matrix!
outimg(Y(:,1), X(1,:)) = outimg(Y(:,1), X(1,:)) + L;

