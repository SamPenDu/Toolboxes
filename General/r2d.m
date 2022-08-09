function d = r2d(r)
%Returns Cohen's d associated Pearson's r.

d = 2*r / sqrt(1-r.^2);