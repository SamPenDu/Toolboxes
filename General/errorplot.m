function h = errorplot(x, y, e, c, w)
%
% h = errorplot(x, y, e, c, [w])
%
% Similar to errorbar but plots solid curve with shaded regions for errors.
% Error regions are equidistant from the curve. The inputs x, y, and e must 
% be row vectors. Each row is a separate data set. If only one row of x is 
% defined the same x is taken for each set. 
%
% If your errors are not symmetric (e.g. confidence intervals) you can also
% provide e as a cell array: e = {lo hi}. In this case the values are not
% errors but the actual limits of the shaded region.
%
% The input c defines the colours of each row. The optional argument w defines 
% the line width of the mean curve.
%
% The optional input w defines the width of the line (default = 2). 
% If this is 0, it plots markers instead.
%
% This function returns the handles of the plot objects so you can use
% the legend function.
%

if nargin < 4
    c = 'lines';
    w = 2;
elseif nargin < 5 
    w = 2;
end
if isempty(c)
    c = 'lines';
end

% determine colour map
if ischar(c)
    c = colormap([c '(' num2str(size(y,1)) ')']);
end

% plot figure
hold on

% if only one row of x defined 
if size(x,1) == 1
    x = repmat(x, size(y,1), 1);
end

% x values for error region
ex = [x, fliplr(x)];
if isa(e, 'cell')
    % if confidence interval
    ey = [e{1}, fliplr(e{2})];
else
    % if error bars
    ey = [y-e, fliplr(y)+fliplr(e)];
end

% superimpose transparent polygon
for i = 1:size(y,1)
    col = (c(i,:)+[1 1 1]) / 2;
    fill(ex(i,:), ey(i,:), col, 'EdgeColor', col, 'FaceAlpha', 0.5);
end

% plot the curves 
h = [];
for i = 1:size(y,1)
    col = c(i,:);
    if w == 0
        h = [h; plot(x(i,:), y(i,:), 'Color', col, 'MarkerFaceColor', col, 'Marker', 'o', 'LineStyle', 'none')];
    else
        h = [h; plot(x(i,:), y(i,:), 'Color', col, 'MarkerFaceColor', col, 'LineWidth', w)];
    end
end
hold off
