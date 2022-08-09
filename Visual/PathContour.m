function xy = PathContour(curvature, rotation, linelength)
%xy = PathContour(curvature, rotation, [linelength])
%
% Generates a contour path describing a sine wave.
% 
% Parameters
%   curvature :      Curvature of the path (sine wave amplitude)
%   rotation :       Rotation (degrees) counter-clockwise from 3 o'clock 
%   linelength :     Length (optional, default = 1.2)
%
% Returns matrix of points on the shape.

if nargin < 3
    linelength = 1.2;
end

xy = [];

%calculate each location on the contour
for r = -linelength/2 : 0.01 : linelength/2
    xy = [xy; r cosd(r/linelength*180)*curvature];
end

%rotate if it necessary
if rotation ~=0
    rads = rotation / 180*pi;
    [t r] = cart2pol(xy(:,1), xy(:,2));
    t = t - rads;
    [x y] = pol2cart(t, r);
    xy = [x y];
end