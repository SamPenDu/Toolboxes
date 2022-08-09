function p = p_nod(A,B)
%
% p = p_nod(A,B)
%
% Estimates the non-overlapping proportion of two distributions (e.g. bootstrap samples).
% This can be regarded as the strength of evidence that the two distributions are different.
%

% Smoothed distributions, sampled separately
[na xa] = ksdensity(A);
[nb xb] = ksdensity(B);

% Parameters for sampling
lo = min([xa xb]);
hi = max([xa xb]);
s= min([xa(2)-xa(1) xb(2)-xb(1)]);

% Smoothed distribution with common sampling
[na xa] = ksdensity(A, lo:s:hi);
[nb xb] = ksdensity(B, lo:s:hi);

% Differences in numbers
d = abs(nb-na);

% Proportion of non-overlapping probabilities
p = sum(d) / (sum(na) + sum(nb));