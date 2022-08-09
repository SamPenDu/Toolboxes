function OutStim = JitterLaterally(InStim, Jitter, Unifrm)
%OutStim = JitterLaterally(InStim, Jitter, [Unifrm])
%
% Adds lateral jitter to the contour. The base orientation 
% is assumed to be collinear (which shouldn't change usually). 
% Note that this routine does not check for minimum distance 
% so overlap with other elements is possible!
%
% Parameters:
%   InStim :    Stimulus struct with contour
%   Jitter :    Jitter level 
%   Unifrm :    Distribution to use :
%                  1 = Uniform
%                  0 = Normal (default)
%
% Returns the transformed stimulus structure.
%

if nargin < 3
    Unifrm = 0;
end

OutStim = InStim;

%find the contour elements
con = find(InStim.IsContour == 1);

for i = 1 : length(con)
    if Unifrm == 1
        J = rand * 2*Jitter - Jitter;
    else
        J = randn * Jitter;
    end
    
    [x y] = pol2cart((InStim.Collinear(con(i))+90) / 180*pi, J);
    
    OutStim.X(con(i)) = InStim.X(con(i)) + x;
    OutStim.Y(con(i)) = InStim.Y(con(i)) + y;
end

