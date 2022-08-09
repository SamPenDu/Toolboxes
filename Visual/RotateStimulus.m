function OutStim = RotateStimulus(InStim,Ori)
%OutStim = RotateStimulus(InStim,Ori)
%
% Rotates the stimulus defined by InStim.
%
% Parameters:
%   InStim :   Input stimulus struct
%   Ori :      Rotation angle (in degrees)
%
% Returns the transformed stimulus.
%

%create rotated matrix
OutStim = InStim;

%rotate the elements
OutStim.Theta = OutStim.Theta + Ori;
OutStim.Collinear = OutStim.Collinear + Ori;

for i = 1 : InStim.N 
    [t r] = cart2pol(OutStim.X(i), OutStim.Y(i)); 
    t = t - Ori/180*pi; 
    [x y] = pol2cart(t,r); 
    OutStim.X(i) = x; 
    OutStim.Y(i) = y; 
end
