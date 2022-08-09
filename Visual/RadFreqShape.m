function xy = RadFreqShape(radfreq, rotation, paramvec)
%xy = RadFreqShape(radfreq, rotation, paramvec)
%
% Generates a radial frequency shape.
% 
% Parameters
%   radfreq :   Radial frequency ie. the number of leaves
%                   (If this is a scalar the second component has half the frequency of the first.
%                    If it is a 1 x 2 vector it defines frequencies for both components.)
%   rotation :  Rotation (degrees) counter-clockwise from 3 o'clock 
%   paramvec :  Vector with parameters of the shape: 
%                   1) Radius of the base circle
%                   2) Amplitude of first component 
%                   3) Amplitude of second component
%                   4) Phase of the second component 
%                   5) Eccentricity of the ellipse (0 = circular)
%                  [6) Optional! Size of a segment cut in degrees
%                       (The segment is at the starting point)]
%
% Returns matrix of points on the shape.
%

%parameters for the functions
radius = paramvec(1);    
ampl1 = paramvec(2);    
ampl2 = paramvec(3);
pha2 = paramvec(4);
ecc = paramvec(5);
if length(paramvec) > 5
    segcut = round(paramvec(6) / 2);
else
    segcut = 0;
end

xy = [];

if length(radfreq) == 1
%second frequency is undefined
    %second = first / 2
    if mod(radfreq,2) 
        radfr2 = floor(radfreq/2);
    else
        radfr2 = radfreq/2 - 1;
    end
else
%second frequency is defined 
    radfr2 = radfreq(2);
    radfreq = radfreq(1);
end

%calculate each location on the contour
for theta = 1+segcut : 0.1 : 360-segcut
    %calculate radius of shape at this angle;
    r = radius * (1 + ampl1 * cos(radfreq*(theta/180*pi))) ...
               * (1 + ampl2 * cos(radfr2*(theta/180*pi)+(pha2/180*pi))) ...
               * sqrt(1-ecc^2) / sqrt(1-ecc^2*cos(theta/180*pi)^2);
    [x y] = pol2cart( (theta/180*pi - rotation/180*pi), r);     
    xy = [xy; x y];
end

