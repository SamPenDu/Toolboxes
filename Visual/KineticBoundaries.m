function RndDotKin = KineticBoundaries(Width, Orientation, Velocity, NumDots, DotWidth)
%RndDotKin = KineticBoundaries(Width, Orientation, Velocity, NumDots, DotWidth)
%
% Generates stimulus structure for kinetic boundaries.
%
% Parameters:
%   Width :         Width of the moving bars (in stimulus space)
%                       If this is a vector, the second element defines
%                       the phase offset of the boundaries
%   Orientation :   Orientation of the bars
%   Velocity :      Velocity of the moving dots
%   NumDots :       Total number of dots
%   DotWidth :      Width of dots
%
% Returns a stimulus structure. The dots always have infinite life and the
% direction of motion is always along the stripes.
%

if length(Width) == 1
    Width(2) = 0;
end

% Create an ordinary random dot kinetogram
RndDotKin = RandomDotKinetogram(1, 90, Velocity, NumDots, DotWidth);

% Reverse direction in some stripes
RndDotKin.Theta = Orientation - RndDotKin.Theta .* mod(ceil((RndDotKin.Y+Width(2)) ./ Width(1)),2)*2-1;

% Rotate the stimulus to get appropriate orientation
for i = 1 : RndDotKin.N 
    [t r] = cart2pol(RndDotKin.X(i), RndDotKin.Y(i)); 
    t = t + Orientation / 180*pi; 
    [x y] = pol2cart(t,r); 
    RndDotKin.X(i) = x; 
    RndDotKin.Y(i) = y; 
end
