function PlotIdLine(Colour, LineWidth)
%
% PlotIdLine(Colour)
%
% Plots an identity line onto a plot. 
% It automatically turns hold on & makes axis square.
% Colour defines the colour (defaults to black).
% LineWidth defines the line width (defaults to 2).

if nargin < 1
    Colour = 'k';
end
if nargin < 2
    LineWidth = 2;
end

hold on
axis square
x = xlim;
y = ylim;
a = [min([x y]) max([x y])];
line(a, a, 'color', Colour, 'linewidth', LineWidth);
axis([a a]);
yticks(xticks);
