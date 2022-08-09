function outputimg = WhiteNoiseDot(inputimg, sigma, xpos, ypos, contr, segm)
%outputimg = WhiteNoiseDot(inputimg, sigma, xpos, ypos, [contr, segm])
%
% Draws a Gaussian white noise dot with specified parameters into the input image.
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of Gaussian envelope
%   xpos :      X pixel coordinate of the Gaussian centre in the image 
%   ypos :      Y pixel coordinate of the Gaussian centre in the image
%   contr :     Optional, defines the contrast of the Gaussian between 0-1
%   segm :      Optional, defines the segment missing of the Gaussian
%                This is a 1x3 vector defining start/finish polar angle and the radius, respectively.
%
% The function returns the new image containing the new Gaussian element.
%

% If contrast undefined it is 100%
if nargin < 5
    contr = 1;
    segm = 0;
elseif nargin < 6
    segm = 0;
end

% Create output image
outputimg = inputimg;
dims = size(outputimg);

% Coordinates of all pixels of the Gaussian relative to its centre
[X Y] = meshgrid(-3*sigma : 3*sigma, -3*sigma : 3*sigma);

% White noise matrix
N = double(rand(size(X)) > 0.5)*2 - 1;

% Luminance modulation at each pixel:
%  L = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%           Gaussian                                                              
L = exp(-(X.^2)./(2*sigma.^2)-(Y.^2)./(2*sigma.^2)) * contr/2 .* N;
if size(segm,2) == 3
    segm(1:2) = NormDeg(segm(1:2));
    T = NormDeg(-atan2(Y,X)/pi*180);
    R = sqrt(X.^2 + Y.^2);
    if segm(1) > segm(2)
        S = (T >= segm(1) & T <= 360 & R <= segm(3)) | (T >= 0 & T <= segm(2) & R <= segm(3));
    else
        S = (T >= segm(1) & T <= segm(2) & R <= segm(3));
    end
    L(S) = 0;
end

% Round too subtle background values
L(L>4.999 & L<5.001) = 0.5;

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
outputimg(Y(:,1), X(1,:)) = outputimg(Y(:,1), X(1,:)) + L;
