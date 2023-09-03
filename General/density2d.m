function [D, gx, gy] = density2d(X, Y, col, xyl, gc, nrm)
%
% [D, gx, gy] = density2d(X, Y, col, xyl, gc, nrm)
%
% Plots a 2D density histogram of variable X vs Y.
%
%   col:    Optional, defines the colourmap to be used (e.g. 'hot').
%           If this is preceded by '-', it is inverted.
%           Can also contain any 1*3 colour value or colour string (e.g. 'r') 
%             which defines the colour of the contour lines instead.
%
%   xyl:    Optional, defines the axis dimenions (see axis function).
%
%   gc:     Optional, defines the coarseness of the contour plot.
%
%   nrm:    Optional, toggles how the density is normalised:
%               0 = no normalisation (default)
%               1 = normalise to peak
%              -1 = logarithmic transformation
%       
% Returns in D the density matrix & in gx and gy the coordinates for plotting.

if nargin < 3
    col = 'fire';
end

% Grid parameters
if nargin < 4
    xyl = [min(X) max(X) min(Y) max(Y)];
end
if nargin < 5
    gc = 40;
end
rx = range(xyl(1:2))/(gc*2);
ry = range(xyl(3:4))/(gc*2);
[gx gy] = meshgrid(xyl(1)+rx:rx*2:xyl(2)-rx, xyl(3)+ry:ry*2:xyl(4)-ry);

% Normalisation
if nargin < 6
    nrm = 0;
end

% Determine density
D = NaN(gc,gc);
for ix = 1:gc
    for iy = 1:gc
        D(ix,iy) = sum(X>=gx(ix,iy)-rx & X<gx(ix,iy)+rx & Y>=gy(ix,iy)-ry & Y<gy(ix,iy)+ry);
    end
end

% Normalize?
if nrm
    D = D / max(D(:));
end
% Logarithmic transformation?
if nrm < 0
    D = -log(D);
end

% Contour plot
if nargout == 0
    if ischar(col) && length(col) > 1
        contourf(gx, gy, D, gc, 'linestyle', 'none');
        if col(1) == '-'
            col = col(2:end);
            cm = colormap(col);
            colormap(flipud(cm));
        else
            colormap(col);
        end
    else
        contour(gx, gy, D, gc, 'color', col);
    end
    axis square
end