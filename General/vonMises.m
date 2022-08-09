function y = vonMises(x,m,k)
%
% y = vonMises(x,m,k)
%
% Returns the output of the von Mises probability density function for
% orientation x (in radians), peak m, and dispersion k (larger = narrower).
%

y = exp(k.*cos(x-m)) / (2*pi.*besseli(0,k));