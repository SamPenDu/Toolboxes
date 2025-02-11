function h = ScatterPlot(X, Y, Colour, IsRobust)
%
% Plots the data in Y against X with regression lines and confidence regions.
%
%   Colour:     Plot colour as a RGB vector (default = [0 0 0])
%   IsRobust:   If this is true uses a robust fit (default = false)
%

% Default parameters
if nargin < 3
    Colour = [0 0 0];
end
if nargin < 4
    IsRobust = false;
end

% Plot to get dimensions
scatter(X, Y, 100, 'k', 'filled'); 
set(gca, 'fontsize', 15);
axis square
xl = xlim; yl = ylim;

% Bootstrapped regression lines
x = xl(1)-range(xl):range(xl)/100:xl(2)+range(xl); % X-vector for confidence curve
if IsRobust
    bF = bootstrp(10000, @robustfit, X, Y);    
    bF = fliplr(bF); % Slope is first
else
    bF = bootstrp(10000, @polyfit, X, Y, 1);
end
Ys = bF(:,1) .* repmat(x,10000,1) + bF(:,2);

% Regression confidence region
Ci = prctile(Ys, [2.5 97.5]);
fill([x fliplr(x)], [Ci(1,:) fliplr(Ci(2,:))], (Colour+[1 1 1])/2, 'EdgeColor', Colour, 'FaceAlpha', 0.5);
hold on

% Scatter plots
h = scatter(X, Y, 100, Colour, 'filled'); 
set(gca, 'fontsize', 12);
axis square
grid on

% Regression lines
if IsRobust
    F = robustfit(X, Y);
    F = fliplr(F'); % Slope is first
    Cs = correl(X,Y,'s');
else
    F = polyfit(X, Y, 1);
    Cs = correl(X,Y);
end
plot(xl, F(1)*xl + F(2), 'color', Colour, 'linewidth', 3);
axis([xl yl]); 
title(Cs);
