function linerect(xy, col, wid, sty)
%linerect([x1 y1 x2 y2], col, wid, sty)
% Draws a rectangle from line objects with coordinates 1 and 2.
%
% Parameters:
%   [x1 y1 x2 y2] : Coordinates of rectangle
%   col : Optional, color
%   wid : Optional, width
%   sty : Optional, line style

if nargin < 2
    col = 'k';
    wid = 1;
    sty = '-';
elseif nargin < 3
    wid = 1;
    sty = '-';
elseif nargin < 4
    sty = '-';
end

x1 = xy(1); y1 = xy(2);
x2 = xy(3); y2 = xy(4);

hold on;
% Horizontal lines
line([x1 x2], [y1 y1], 'Color', col, 'LineWidth', wid, 'LineStyle', sty);
line([x1 x2], [y2 y2], 'Color', col, 'LineWidth', wid, 'LineStyle', sty);
% Vertical lines
line([x1 x1], [y1 y2], 'Color', col, 'LineWidth', wid, 'LineStyle', sty);
line([x2 x2], [y1 y2], 'Color', col, 'LineWidth', wid, 'LineStyle', sty);
