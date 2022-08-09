function cormatcols(R)
% Rescales the colour axis in a correlation matrix created with imcormat.

caxis([-1 +1]/2*R + 0.5);
hb = colorbar;
set(hb, 'ytick', [-1:.5:+1]/2*R + 0.5, 'yticklabel', -R:R/2:R);
