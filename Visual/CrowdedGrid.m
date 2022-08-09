function stim = CrowdedGrid(xy, nelems)
%stim = CrowdedGrid(xy, nelems)
%
% Embeds a contour string of points in a random background. 
%
% Parameters:
%   xy :        String of points on the contour
%   nelems :    Number of elements in the contour
%
% Returns stimulus structure.
%

% extremely crowded Gabor field
[cont dfg] = CollinearContour(xy, nelems);
stim = GridBackground(cont, dfg/2, 1);

% random order of element indeces
conels = find(stim.IsContour == 1);
bgdels = find(stim.IsContour == 0);
e = randperm(length(bgdels));
bgdels = bgdels(e);

els = [conels; bgdels(1:floor(length(bgdels)/2))];

stim.N = length(els);
stim.X = stim.X(els);
stim.Y = stim.Y(els);
stim.Theta = stim.Theta(els);
stim.Collinear = stim.Collinear(els);
stim.IsContour = stim.IsContour(els);
stim.Contrast = stim.Contrast(els);
stim.Phase = stim.Phase(els);
stim.Sigma = 10;
stim.Lambda = 5;
