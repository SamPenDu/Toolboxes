function elem = AlignToPath(xy, i)
%elem = AlignToPath(xy, i)
%
% Determines the orientation of a collinear Gabor element at 
% a specified point on the contour (string of coordinates).  
%
% Parameters:
%   xy :    m x 2 matrix with string of coordinates
%   i :     Index of the element on the string xy
%
% Returns a vectir struct with elements: 
%   Orientation,  X-coordinate,  Y-coordinate
%

%indeces of previous and next point on string 
next = i+1;
prev = i-1;

%make sure the string is connected to its origin
if next > size(xy,1)
    next = 1;
end
if prev < 1
    prev = size(xy,1);
end

%orientation of a line between prev and next
v = xy(next,:) - xy(prev,:);
ori = atan2(v(2), v(1)) * 180/pi;

%return a vector with the element parameters
%(orientation is negative because of MatLab matrix format)
elem = [NormDeg(ori) xy(i,:)]; 
