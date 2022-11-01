function d = t2d(t,df)
%Returns Cohen's d for a t-statistic & degrees of freedom in a two-sample t-test.

d = 2*t / sqrt(df);