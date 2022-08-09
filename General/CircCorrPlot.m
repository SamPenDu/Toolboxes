function h = CircCorrPlot(X, Y, nb)
% 
% Plots a polar plot of the deviation between angles in vectors X and Y 
% and also states the circular correlation coefficient and the angular deviation. 
% The optional third  input defines the number of histogram bins (default = 36). 
%

if nargin < 3
    nb = 36; % Number of bins
end
w = 360 / nb; % Bin width
bins = (0:w:360-w) / 180 * pi; % Bins to calculate

% Calculate deviations
D = NormDeg(Y) - NormDeg(X); % Difference between angles
D = NormDeg(D); % Normalise to be between 0-360 deg
D(D >= 180) = D(D >= 180) - 360; % Angles above 180 deg are negative

% Plot results
h = rose(D / 180 * pi, bins); % Polar histogram
title({['r_c = ' n2s(circcorr(X,Y))]; ['\sigma = ' n2s(circdev(X,Y))]}); % Circular correlation coefficient