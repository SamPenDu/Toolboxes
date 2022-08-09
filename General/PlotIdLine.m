function PlotIdLine(Colour)
%
% PlotIdLine(Colour)
%
% Plots an identity line onto a plot. 
% It automatically turns hold on & makes axis square.
% Colour defines the colour (defaults to black).

if nargin < 1
    Colour = 'k';
end

hold on
axis square
x = xlim;
y = ylim;
a = [min([x y]) max([x y])];
line(a, a, 'color', Colour, 'linewidth', 2);
