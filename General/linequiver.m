function h = linequiver(xy1, xy2, col, lin)
%
% h = linequiver(xy1, xy2, [col='k', lin=2])
%
% Different style quiver plot than Matlab's own.
% Each dot shows the shifted position and the line denotes where it has shifted from.
%
%   xy1:    n*2 matrix of baseline x and y positions 
%   xy2:    n*2 matrix of shifted x and y positions
%   col:    color of lines and symbols
%   lin:    line width
%
% Returns the figure handle.
%

if nargin < 3
    col = 'k';
end
if nargin < 4
    lin = 2;
end

hold on
for i = 1:size(xy1,1)
    line([xy1(i,1) xy2(i,1)], [xy1(i,2) xy2(i,2)], 'color', col, 'linewidth', lin);
end
scatter(xy2(:,1), xy2(:,2), 30, col, 'filled');
h = gcf;

