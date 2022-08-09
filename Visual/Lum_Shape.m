function OutStim = Lum_Shape(Stim, Mask)
%OutStim = RDK_Shape(Stim, Mask)
%
% Shape defined by luminance of dots. The image Mask defines which 
% dot colour is displayed at this location and returns each stimulus. 
% 
% Parameters:
%   Stim :      Stimulus structure with parameters for each element
%   Mask :      Image containing the mask for the kinetic shape
%                   (0 = Black, 1 = White)
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
% Draws the stimulus onto the current sprite and returns the updated structure. 
%

dims = size(Mask)/2;
Mask = round(Mask);

% Stimulus 
Coherent = find(Stim.IsContour == 0);
for i = Coherent'
    % Work out pixel coordinates
    x = round(Stim.X(i) * dims(1)) + dims(1);
    y = round(Stim.Y(i) * dims(2)) + dims(2);
    % Prevent outside pixels
    if x < 1 || x > dims(1)*2
        x = 1;
    end
    if y < 1 || y > dims(1)*2
        y = 1;
    end
    % Determine visibility
    if Mask(y,x) == 1
        Stim.Contrast(i) = 1;
    else
        Stim.Contrast(i) = -1;
    end
end

OutStim = Stim;
