function r = d2r(d)
%Returns Pearson's r associated with a Cohen's d.

r = d / sqrt(d.^2 + 4);