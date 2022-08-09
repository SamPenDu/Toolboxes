function h = PlotLinReg(Betas, Colour, Width)
%
% h = PlotLinReg(Betas, Colour, Width)
%
% Simple wrapper function to plot a linear regression function onto a plot.
% 1x2 vector Betas contains the slope and intercept coefficient. 
% The function plots onto the current figure & turns hold on. 
% It uses xlim to determine range of positions. 
% Colour defines the colour (defaults to black).
%

if nargin < 2
    Colour = 'k';
end
if nargin < 3
    Width = 2;
end

hold on
x = xlim;
h = line(x, x * Betas(1) + Betas(2), 'color', Colour, 'linewidth', Width);
