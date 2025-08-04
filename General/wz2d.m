function [d, r] = z2r(z, n)
% Converts Wilcoxon's signed-rank z to Cohen's d (& also correlation coefficient r).
% n defines the sample size that yielded this z-value.

r = z / sqrt(n); % Correlation coefficient
d = 2 * r ./ sqrt(1 - r.^2); % Convert to Cohen's d





