function [OutStim1 OutStim2] = RDK_Shape(Stim1, Stim2, Mask)
%[OutStim1 OutStim2] = RDK_Shape(Stim1, Stim2, Mask)
%
% Shape defined by kinetic boundaries. The image Mask defines which 
% stimulus is displayed at this location and returns each stimulus. 
%
% This uses the field 'Stim.Collinear' to store colours!!!
% It is imperative that this has been set up first!!!
% 
% Parameters:
%   Stim1 :     Stimulus structure with parameters for each element
%   Stim2 :     Stimulus structure with parameters for each element
%   Mask :      Image containing the mask for the kinetic shape
%                   (0 = Stim1, 1 = Stim2)
%
% The struct Stim contains the parameters:
%   Stim.N =         Number of elements in display
%
% And per element parameters in row vectors:
%   Stim.X =         X-coordinates
%   Stim.Y =         Y-coordinates
%   Stim.Contrast =  Contrast of elements (optional, default = -1 ... 1)
%   Stim.IsContour = Marker for coherently moving dots 
%                       (unlike the Gabor fields, 0 indicates coherence)
%   Stim.Width =     Width of the dots
%   Stim.Annulus =   Optional, defines the inner radius of an annulus aperture
%
% Returns the updated structures. 
%

dims = size(Mask)/2;
Mask = round(Mask);

% Reload backed up colours
Stim1.Contrast = Stim1.Collinear;
Stim2.Contrast = Stim2.Collinear;

% Stimulus 1
Coherent = find(Stim1.IsContour == 0);
for i = Coherent'
    % Work out pixel coordinates
    x = round(Stim1.X(i) * dims(1)) + dims(1);
    y = round(Stim1.Y(i) * dims(2)) + dims(2);
    % Prevent outside pixels
    if x < 1 || x > dims(1)*2
        x = 1;
    end
    if y < 1 || y > dims(1)*2
        y = 1;
    end
    % Determine visibility
    if Mask(y,x) == 1
        Stim1.Contrast(i) = NaN;
    end
end

% Stimulus 2
Coherent = find(Stim2.IsContour == 0);
for i = Coherent'
    % Work out pixel coordinates
    x = round(Stim2.X(i) * dims(1)) + dims(1);
    y = round(Stim2.Y(i) * dims(2)) + dims(2);
    % Prevent outside pixels
    if x < 1 || x > dims(1)*2
        x = 1;
    end
    if y < 1 || y > dims(1)*2
        y = 1;
    end
    % Determine visibility
    if Mask(y,x) == 0
        Stim2.Contrast(i) = NaN;
    end
end

OutStim1 = Stim1;
OutStim2 = Stim2;
