function img = OriBiasGabors(bmap, centel)
%img = OriBiasGabors(bmap[, centel])
% Plots the orientation bias map with Gabors.
% The map is defined in bmap N x [theta, rho]. 
% If centel is ~=0, a central horizontal Gabor
% is placed into the plot as reference element.
% Returns an image matrix of the map.
%

if nargin < 2
    centel = 0;
end

polbins = size(bmap,1);
angres = 360 / polbins;

%initialize the display stimulus 
Stim = struct;
Stim.N = size(bmap,1) + 1;
Stim.X = 0;
Stim.Y = 0;
Stim.Theta = 0;
Stim.Collinear = 0;
Stim.IsContour = 1;
Stim.Contrast = 1;
Stim.Phase = 0;

%if no reference move it to infinity
if centel == 0
    Stim.X = Inf;
    Stim.Y = Inf;
end

for i = 1 : polbins
    theta = i * angres;
    [x y] = pol2cart(theta / 180*pi, 0.8);
    
    Stim.X = [Stim.X; x];
    Stim.Y = [Stim.Y; y];
    Stim.Theta = [Stim.Theta; bmap(i,1)];
    Stim.Collinear = Stim.Theta; 
    Stim.IsContour = [Stim.IsContour; 0];
    Stim.Contrast = [Stim.Contrast; bmap(i,2)];
    Stim.Phase = [Stim.Phase; 0];
end

Stim.Sigma = 20;
Stim.Lambda = 30;

WinDim = 400;

img = GaborField(Stim,WinDim);
