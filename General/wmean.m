function [wm wv] = wmean(x,w)
%
% [wm wv] = wmean(x,w)
%
%   Calculates weighted mean wm and its variance wv of x 
%   using the weights w. NaNs are ignored.
%
 
% Normalise weights
w = w ./ nansum(w);

% Calculate weighted mean & variance
wm = nansum(x .* w);
wv = nansum(w .* (x-wm).^2);


