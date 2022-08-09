function [R P uR uP] = wcorr(X, w, DispOn)
%
% [R P uR uP] = wcorr(X, w, [DispOn=false])
%
% Weighted Pearsons correlation between columns in X with rows weighted by vector w.
% Returns R and P of weighted correlation, and uR and uP of unweighted correlation.
% Rows containing NaNs are automatically removed.
%
% The optional input argument DispOn toggles a scatter plot display. 
% This however only works if there are only two columns in X.
%

if nargin < 3
    DispOn = false;
end

% Output variables
R = NaN(size(X,2), size(X,2));
P = NaN(size(X,2), size(X,2));

% Sample size
n = size(X,1);

% Remove NaNs
ns = ~isnan(sum(X,2));
X = X(ns,:);
w = w(ns);

% Weights should be column vector
if size(w,2) > 1
    w = w';
end

% Unweighted correlation
[uR uP] = corr(X);

% Weighted means
mX = sum(X.*repmat(w,1,size(X,2))) / sum(w);

% Loop through pairs of columns
for r = 1:size(X,2)
    for c = 1:size(X,2)
        % Weighted covariance matrices
        crc = sum(w.*(X(:,r)-mX(r)).*(X(:,c)-mX(c)));
        crr = sum(w.*(X(:,r)-mX(r)).*(X(:,r)-mX(r)));
        ccc = sum(w.*(X(:,c)-mX(c)).*(X(:,c)-mX(c)));

        % Weighted correlation
        R(r,c) = crc / sqrt(crr*ccc);

        % Significance
        t = r2t(R(r,c),sum(w));
        P(r,c) = p_value(t,sum(w)-2);
    end
end

% No matrix if only two columns in X
if size(X,2) == 2
    R = R(1,2);
    P = P(1,2);
    uR = uR(1,2);
    uP = uP(1,2);
end

% Scatter plot?
if DispOn && size(X,2) == 2
    % Scatter plot with weights 
    scatter(X(:,1), X(:,2), 50, w, 'filled');
    colormap(flipud(gray));
    axis square
    hold on
    
    % Regression line
    b1 = R * std(X(:,2)); % Slope
    b0 = mean(X(:,2)); % Intercept
    xl = xlim;
    line(xl, (xl-mean(X(:,1))).*b1+b0, 'color', 'k', 'linewidth', 2);
    
    % Denote correlation
    title(['r = ' n2s(round_decs(R,2)) ', p = ' n2s(round_decs(P,4))]);
end
