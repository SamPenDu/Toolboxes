function ad = circdev(X, Y)
% 
% Calculates the angular error between two sets of angles in vectors X and Y. 
% Specifically, this is median standard deviation over the absolute differences 
% between the two angles. This is a more robust measure of polar map
% similarity than the circular correlation.
%

% Calculate deviations
D = NormDeg(Y) - NormDeg(X); % Difference between angles
D = NormDeg(D); % Normalise to be between 0-360 deg
D(D >= 180) = D(D >= 180) - 360; % Angles above 180 deg are negative
ad = mad(abs(D), 1); % Standard deviation of angles

