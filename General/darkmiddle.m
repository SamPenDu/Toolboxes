function dmap = darkmiddle(cmap)
%
% dmap = darkmiddle(cmap)
%
% Darkens the mid-section of colourmap cmap.
%

half = floor(size(cmap,1)/2);
if isodd(size(cmap,1))
    darken = [linspace(1, 0, half)'; 0; linspace(0, 1, half)'];
else
    darken = [linspace(1, 0, half)'; linspace(0, 1, half)'];
end
darken = repmat(darken, 1, 3);

dmap = cmap .* darken;

