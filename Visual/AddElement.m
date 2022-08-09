function OutStim = AddElement(InStim, xy, ori, iscon, contr, phase, sigma, lambda)
%OutStim = AddElement(InStim, xy, ori, iscon, [contr, phase, sigma, lambda])
% Adds an element to the Gabor field stimulus.
%
% Parameters:
%   InStim :    Input stimulus structure
%   xy :        1 x 2 vector with coordinates
%   ori :       Orientation of element
%   iscon :     0 = background, 1 = contour
%   contr :     Contrast of element (default = 1)
%   phase :     Phase of element (default = 0)
%   sigma :     Standard deviation of element (default is same as first element)
%   lambda :    Carrier wavelength of element (default is same as first element)
%

if nargin < 5
    contr = 1;
    phase = 0;
    sigma = 10;
    lambda = 5;
elseif nargin < 6
    phase = 0;
    sigma = 10;
    lambda = 5;
elseif nargin < 7
    sigma = 10;
    lambda = 5;
elseif nargin < 8
    lambda = 5;
end

OutStim = InStim;    

%in case sigma or lambda aren't vectors
if length(OutStim.Sigma) == 1
    OutStim.Sigma = repmat(OutStim.Sigma, OutStim.N, 1);
end
if length(OutStim.Lambda) == 1
    OutStim.Lambda = repmat(OutStim.Lambda, OutStim.N, 1);
end

%add element to stimulus
OutStim.N = OutStim.N + 1;
OutStim.X(end + 1,1) = xy(1);
OutStim.Y(end + 1,1) = xy(2);
OutStim.Theta(end + 1,1) = ori;
OutStim.Collinear(end + 1,1) = ori;
OutStim.IsContour(end + 1,1) = iscon;
OutStim.Contrast(end + 1,1) = contr;
OutStim.Phase(end + 1,1) = phase;
OutStim.Sigma(end + 1,1) = sigma;
OutStim.Lambda(end + 1,1) = lambda;
