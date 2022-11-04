function h = PlotLinReg(Betas, Colour, Width)
%
% h = PlotLinReg(Betas, Colour, Width)
%
% Simple wrapper function to plot a linear regression function onto a plot.
%
% 1x2 vector Betas contains the slope and intercept coefficient. 
% The function plots onto the current figure & turns hold on. 
% It uses xlim to determine range of positions. 
% Colour defines the colour (defaults to black).
%
% If Betas has more than one row, the function bootstraps the regression
%  & plots the confidence region (like in ScatterPlot).
%

if nargin < 2
    Colour = 'k';
end
if nargin < 3
    Width = 2;
end

%% Plot regression
hold on
x = xlim;
if size(Betas,1) == 1
    %% Simple regression
    h = line(x, x * Betas(1) + Betas(2), 'color', Colour, 'linewidth', Width);
else
    %% Bootstrapped regression
    switch Colour
        case 'k'
            Colour = [0 0 0];
        case 'w'
            Colour = [1 1 1];
        case 'r'
            Colour = [1 0 0];
        case 'g'
            Colour = [0 1 0];
        case 'b'
            Colour = [0 0 1];
        case 'c'
            Colour = [0 1 1];
        case 'm'
            Colour = [1 0 1];
        case 'y'
            Colour = [1 1 0];
    end
        
    y = ylim;
    xv = x(1)-range(x):range(x)/100:x(2)+range(x); % X-vector for confidence curve
    Bs = bootstrp(10000, @nanmean, Betas); % Bootstrapped coefficients
    Ys = Bs(:,1) .* repmat(xv,10000,1) + Bs(:,2); % Ys coordinates
    Ci = prctile(Ys, [2.5 97.5]); % 95% confidence region
    fill([xv fliplr(xv)], [Ci(1,:) fliplr(Ci(2,:))], (Colour+[1 1 1])/2, 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Shaded confidence region
    h = line(xv, xv * nanmean(Betas(:,1)) + nanmean(Betas(:,2)), 'color', Colour, 'linewidth', Width); % Mean coefficients
    
    disp(prctile(Bs, [2.5 97.5]));
end
