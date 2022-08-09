function [Stim dfg] = RainPattern(Nconts, Nelems, Curvature, Parallel, LineLen, Rotation, disjitter)
%[Stim dfg] = RainPattern(Nconts, Nelems, [Curvature, Parallel, LineLen, Rotation, disjitter])
%
% Generates a rain pattern, i.e. a stimulus containing several path contours.
%
% Parameters:
%   Nconts :    Number of path contours 
%   Nelems :    Number of elements in each contour
%   Curvature : Curvature of the paths (optional, default = 0)
%   Parallel :  Orientation jitter of the contour orientations (optional, default = 0)
%   LineLen :   Length of the contours (optional, default = 1.2) 
%   Rotation :  Rotation of the shape in degrees (optional, default = 0)
%   disjitter : Spacing jitter of contour elements
%
% Returns the stimulus structure.
%

if nargin < 3
    Curvature = 0;
    Parallel = 0;
    LineLen = 1.2;
    Rotation = 0;
    disjitter = 0;
elseif nargin < 4
    Parallel = 0;
    LineLen = 1.2;
    Rotation = 0;
    disjitter = 0;
elseif nargin < 5
    LineLen = 1.2;
    Rotation = 0;
    disjitter = 0;
elseif nargin < 6
    Rotation = 0;
    disjitter = 0;
elseif nargin < 7
    disjitter = 0;
end

cont = [];
spac = 2 / Nconts;
for nc = -1+spac/2 : spac : 1-spac/2
    GlobOri = 2*Parallel * rand - Parallel;
    xy = PathContour(Curvature, GlobOri, LineLen);
    xy = xy + [repmat(rand*LineLen/2 - LineLen/4, size(xy,1), 1), repmat(nc + rand*spac/2 - spac/4, size(xy,1), 1)];
    [curr dfg] = CollinearContour(xy, Nelems, disjitter);
    cont = [cont; curr];
end

Stim = CombineStimuli(cont);
Stim = RotateStimulus(Stim, Rotation);

%elements inside the stimulus space
inels = find(abs(Stim.X) <= 1 & abs(Stim.Y) <= 1);
Stim.N = length(inels);
Stim.X = Stim.X(inels);
Stim.Y = Stim.Y(inels);
Stim.Theta = Stim.Theta(inels);
Stim.Collinear = Stim.Collinear(inels);
Stim.IsContour = Stim.IsContour(inels);
Stim.Contrast = Stim.Contrast(inels);
Stim.Phase = Stim.Phase(inels);
Stim.Sigma = Stim.Sigma(inels);
Stim.Lambda = Stim.Lambda(inels);
