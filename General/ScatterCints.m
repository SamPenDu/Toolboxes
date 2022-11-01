function h = ScatterCints(X, Y)
%
% h = ScatterCints(X, Y)
%
% Scatter plot with error bars reflecting bootstrapped confidence intervals.
%
%   X & Y contain the bootstrap iterations for each subject/observation in the data sample.
%    So for example if you have five subjects and bootstrapped their result 10000 times,
%    this is a 10000-by-5 matrix where each row is a bootstrap from a given subject.
%
% This only plots the error bars but no symbols or regression lines etc. 
% If you want those you also need to an appropriate function for that.
%
% 01/11/2022 - Written (DSS)
%

h = gcf;
% Mean per subject/observation
Xmu = nanmean(X);
Ymu = nanmean(Y);
% Confidence interval per subject/observation
Xci = prctile(X, [2.5 97.5]);
Yci = prctile(Y, [2.5 97.5]);
% Scatter plot with errors
errorbar(Xmu, Ymu, Ymu-Yci(1,:), Ymu-Yci(2,:), Xmu-Xci(1,:), Xmu-Xci(2,:), 'color', 'k', 'linestyle', 'none');
