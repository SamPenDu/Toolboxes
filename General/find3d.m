function [x y z] = find3d(expr)
%
% [x y z] = find3d(expr)
%
% Finds coordinates in a 3d-matrix. This works like 'find' but returns
%   the x,y,z (or row, column & page, if you will) instead.
%

[r c] = find(expr);
x = r;
y = mod(c, size(expr,2));
y(y == 0) = size(expr,2);
z = ceil(c/size(expr,2));
