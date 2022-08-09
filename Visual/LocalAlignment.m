function OutStim = LocalAlignment(InStim, Condition, Ori)
%OutStim = LocalAlignment(InStim, Condition, [Ori])
%
% Transforms the contour to a different alignment condition.
%
% Parameters:
%   InStim :        Stimulus struct with contour
%   Condition :     Char indicating the condition (only first letter matters):
%                       'Collinear' =   elements are aligned with the path
%                       'Orthogonal' =  elements are perpendicular to the path
%                       'Acute' =       elements are oriented at an angle to the path
%                       'Parallel' =    elements all have the same orientation
%   Ori :           Orientation for Acute and Parallel (optional, default = 45)
%
% Returns the transformed stimulus structure.
%

OutStim = InStim;

Condition = upper(Condition);

if nargin < 3
    Ori = 45;
end

switch Condition(1)
    case {'C' 'c'}
        Misalmt = 0;
    case {'O' 'o'}
        Misalmt = 90;
    case {'A' 'a'}
        Misalmt = Ori;
end

%find the contour elements
con = find(InStim.IsContour == 1);

if strcmpi(Condition(1), 'P')
    OutStim.Theta(con) = Ori;
else
    for i = 1 : length(con)
        OutStim.Theta(con(i)) = InStim.Collinear(con(i)) + Misalmt;
    end
end
