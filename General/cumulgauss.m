function y = cumulgauss(x, c, s)
%
% y = cumulgauss(x, c, s)
%
%   Returns value y for cumulative gaussian given by coefficients
%   c = centroid; s = standard deviation
%

x = double(x);
y = 0.5 * (1 + erf((x-c)/(sqrt(2)*s)));
