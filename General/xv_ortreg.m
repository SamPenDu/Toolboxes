function [Sigma mBs Rs Bs] = xv_ortreg(X, Y, Z_normalise, DispOn)
%
% [Sigma mBs Rs Bs] = xv_ortreg(X, Y, Z_normalise, [DispOn=true])
%
% Leave-one-out cross-validation of an orthogonal regression (1st eigenvector) of X vs Y.
% Returns in Sigma the standard deviation of residuals, in mBs the mean betas, in Rs the 
% residuals for each point (orthogonal & null), and in Bs the betas for each fold. 
% The optional inputs Z_normalise first performs z-score normalisation & DispOn toggles displays.
%
% Written by Sam Schwarzkopf at UCL (s.schwarzkopf@ucl.ac.uk).
%

if nargin < 3
    Z_normalise = false;
    DispOn = true;    
elseif nargin < 4
    DispOn = true;
end

%% Z-normalise
if Z_normalise
    X = zscore(X);
    Y = zscore(Y);
end

%% Predictions & Betas
Cs = NaN(2,2,2);
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
    % Indeces of model & test sets
    m = 1:size(X,1);
    m(i) = [];
    t = i;
    
    % Data for building the model
    modelX = X(m,:); modelX = modelX(:);
    modelY = Y(m,:); modelY = modelY(:);
    
    % Data for testing model prediction
    testX = X(t,:); testX = testX(:);
    testY = Y(t,:); testY = testY(:);
    
    % Summary stats for model set
    muX = mean(modelX);
    muY = mean(modelY);
    sigmaX = std(modelX);
    sigmaY = std(modelY);
        
    % Orthogonal regression model (1st eigenvector) on standardised data
    c = ortreg((modelX-muX)/sigmaX, (modelY-muY)/sigmaY);
    if isempty(c)
        c = NaN(2,2);
    end
    Cs(:,:,i) = c; % Add to coefficient matrix
    % Betas of function (1st eigenvector)
    b = (c(1,1)*sigmaY) / (c(2,1)*sigmaX); 
    b = [b, b * -muX + muY];

    % Predict test data
    lambda = sigmaY^2 / sigmaX^2; % Scale factor   
    predX = testX + b(1)./(b(1).^2 + lambda) * (testY - b(2) - b(1)*testX);
    predY = b(2) + b(1)*predX;
    r = sqrt((predX-testX).^2 + (predY-testY).^2); % Residual
    
    % Store in matrices
    Rs = [Rs; r];
    Bs = [Bs; b];

    % Plot regression
    if DispOn
        % Orthogonal regression
        line(xl, xl*b(1)+b(2), 'linewidth', 2, 'color', [.7 .7 .7]);
        hold on
    end
end

%% Orthogonal regression
% Mean coefficients 
mCs = nanmean(Cs,3);
% Standard deviation of residuals
Sigma = nanstd(Rs); 
% Betas of function (1st eigenvector)
mBs = (mCs(1,1)*std(Y(:))) / (mCs(2,1)*std(X(:)));
mBs = [mBs, mBs * -mean(X(:)) + mean(Y(:))];

%% Replot raw data & mean regression
if DispOn
    h1 = line(xl, xl*mBs(1)+mBs(2), 'linewidth', 2, 'color', 'k');
    h2 = scatter(X(:), Y(:), 50, [1 1 1]/2, 'filled', 'markeredgecolor', 'k');
    set(gca, 'fontsize', 12);
    title({['y = ' sprintf('%1.2f',b(1)) 'x + ' sprintf('%1.2f',b(2))]; ['\sigma = ' sprintf('%1.2f',Sigma)]});
    legend([h2 h1], {'Observed data' 'Crossvalidation'});
end


%% Orthogonal regression
function Coefs = ortreg(X,Y)
% Using PCA for orthogonal regression.
%   X and Y must be z-scored!

% Ensure inputs are column vectors
if size(X,1) == 1
    X = X';
end
if size(Y,1) == 1
    Y = Y';
end

% Principal component analysis
[Coefs,tXY] = pca([X Y]);

