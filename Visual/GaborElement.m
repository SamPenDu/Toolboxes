function outputimg = GaborElement(inputimg, sigma, theta, lambda, phase, xpos, ypos, contr, segm)
%outputimg = GaborElement(inputimg, sigma, theta, lambda, phase, xpos, ypos, [contr, segm])
%
% Draws a Gabor with specified parameters into the input image.
%
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of Gaussian envelope
%   theta :     Orientation of the carrier (0 deg = 3 o'clock, positive is counter-clockwise)
%   lambda :    Wavelength of the carrier
%   phase :     Phase of the carrier (cosine grating so 0 deg = light peak in middle)
%   xpos :      X pixel coordinate of the Gabor centre in the image 
%   ypos :      Y pixel coordinate of the Gabor centre in the image
%   contr :     Optional, defines the contrast of the Gabor between 0-1
%   segm :      Optional, defines the segment missing of the Gaussian
%                   This is a 1x3 vector defining start/finish polar angle
%                   and the radius, respectively. If this is a 1x4 vector, 
%                   the final component defines the amount of speckling,
%                   that is, how fuzzy the segment edges are.
%
% The function returns the new image containing the new Gabor element.
% Angles and phases are passed in degrees and converted into radians internally.
%

% Check undefined parameters
if nargin < 8
    contr = 1; 
    segm = [0 0 0 0]; 
elseif nargin < 9
    segm = [0 0 0 0];
end

% If segment not fully defined
if isempty(segm)
    segm = [0 0 0 0];
elseif length(segm) == 1
    segm(2:4) = [0 0 0];
elseif length(segm) == 2
    segm(3:4) = [0 0]
elseif length(segm) == 3
    segm(4) = 0;
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

% Luminance modulation at each pixel:
% Gabor function = oriented sinusoidal carrier grating within a Gaussian envelope.
%  L = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%           Gaussian                            Sinusoid    Carrier theta               Wavelength & Phase                                        
L = exp(-((X.^2)./(2*sigma.^2))-((Y.^2)./(2*sigma.^2))) .* (cos(2*pi .* (cos(theta).*X + sin(theta).*Y) ./ lambda + phase)) * contr/2;
if segm(3) > 0
    segm(1:2) = NormDeg(segm(1:2));
    T = NormDeg(-atan2(Y,X)/pi*180) + segm(4) * randn(size(X));
    R = sqrt(X.^2 + Y.^2);
    if segm(1) > segm(2)
        S = (T >= segm(1) & T <= 360 & R <= segm(3)) | (T >= 0 & T <= segm(2) & R <= segm(3));
    else
        S = (T >= segm(1) & T <= segm(2) & R <= segm(3));
    end
    L(S) = 0;
end

% Determine pixel coordinates in the image
X = X + xpos;
Y = Y + ypos;

% Remove pixels outside the image
xrng = X(1,:) > 0 & X(1,:) <= dims(2);
yrng = Y(:,1) > 0 & Y(:,1) <= dims(1);
% X and Y are reversed because image is a MatLab Row x Col matrix!
X = round(X(yrng,xrng));
Y = round(Y(yrng,xrng));
L = L(yrng,xrng);

% Add the modulation of the pixels to the background intensity.
% X and Y are reversed because image is a MatLab Row x Col matrix!
outputimg(Y(:,1), X(1,:)) = outputimg(Y(:,1), X(1,:)) + L;
    

