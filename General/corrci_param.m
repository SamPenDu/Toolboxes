function ci = corrci_param(r,n)
% Returns the parametric 95% confidence interval for correlation r & sample size n.

z = r2z(r);
e = 1 / sqrt(n-3);
zci = [z - 1.96*e, z + 1.96*e];
ci = z2r(zci);