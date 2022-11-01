function t = d2t(d,n)
%Returns t-statistic for a Cohen's d & combined sample size in a two-sample t-test.

t = d*sqrt(n-2) / 2;