function [Stats mBs Rs Bs] = xv_regress(X, Y, DispOn)
%
% [Stats mBs Rs Bs] = xv_regress(X, Y, [DispOn=true])
%
% Leave-one-out cross-validation of a linear regression of X vs Y.
% Returns in Stats the R^2 across folds and the root mean squared error, 
% in mBs the mean betas, in Rs the residuals for each point, and in Bs the 
% betas for each fold. The optional input DispOn toggles displays.
%
% Written by Sam Schwarzkopf at UCL (s.schwarzkopf@ucl.ac.uk).
%

if nargin < 3
    DispOn = true;
end

%% Predictions & Betas
Yh = [];
Rs = [];
Bs = [];

%% Prepare plot
if DispOn
    scatter(X(:), Y(:), 50, 'k', 'filled');
    axis square
    xl = xlim;
end

%% Loop through cross-validations
for i = 1:size(X,1)
    % Indeces of model data set
    x = 1:size(X,1);
    x(x==i) = [];
    
    % Data for building the model
    mX = X(x,:);
    mY = Y(x);
        % Data for testing model prediction
    tX = X(i,:);
    tY = Y(i);
    
    % Linear regression model
    b = regress(mY, [mX ones(size(mX,1),1)]);
    % Predicted values
    yh = sum([tX 1].*b');
    
    % Add to matrices
    Yh = [Yh; yh];
    Rs = [Rs; tY-yh];
    Bs = [Bs; b'];

    % Plot regression
    if DispOn
        % Orthogonal regression
        line(xl, xl*b(1)+b(2), 'linewidth', 2, 'color', [.7 .7 .7]);
        hold on
    end
end

%% Linear regression
% Variance explained by prediction & standard deviation of residuals
Stats = [1-var(Rs)/var(Y) std(Rs)];
% Mean betas of function
mBs = nanmean(Bs);

%% Replot raw data & mean regression
if DispOn
    h1 = line(xl, xl*mBs(1)+mBs(2), 'linewidth', 2, 'color', 'k');
    h2 = scatter(X(:), Y(:), 50, [1 1 1]/2, 'filled', 'markeredgecolor', 'k');
    set(gca, 'fontsize', 12);
    title({['y = ' sprintf('%1.2f',b(1)) 'x + ' sprintf('%1.2f',b(2))]; ['R^2 = ' sprintf('%1.2f',Stats(1)) ', \sigma = ' sprintf('%1.2f',Stats(2))]});
    legend([h2 h1], {'Observed data' 'Crossvalidation'});
end
