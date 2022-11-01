function h = forest(X)
%
% h = forest(X)
%
% Forest plot of bootstrapped confidence intervals per subject/observation.
%
%   X contains the bootstrap iterations for each subject/observation in the data sample.
%    So for example if you have five subjects and bootstrapped their result 10000 times,
%    this is a 10000-by-5 matrix where each row is a bootstrap from a given subject.
%
% 01/11/2022 - Written (DSS)
%

h = gcf;
% 95% confidence interval of sample mean
Cint = prctile(bootstrp(10000, @mean, nanmean(X)), [2.5 97.5]); 
% Mean per subject/observation
Xmu = nanmean(X);
% Confidence interval per subject/observation
Xci = prctile(X, [2.5 97.5]);
% Scatter plot with errors
errorbar(Xmu, 2:length(Xmu)+1, Xmu-Xci(1,:), Xmu-Xci(2,:), 'horizontal', 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'linestyle', 'none');
hold on
% Show grand mean
errorbar(mean(Xmu), 1, Cint(1)-mean(Xmu), Cint(2)-mean(Xmu), 'horizontal', 'color', 'k', 'marker', 'd', 'markerfacecolor', 'k', 'markersize', 10);
% Cosmetic changes
axis square
set(gca, 'fontsize', 12);
title(['M = ' num2str(round(mean(Xmu),2)) ' [' num2str(round(Cint(1),2)) ', ' num2str(round(Cint(2),2)) ']']);
set(gca, 'ytick', 1:length(Xmu)+1, 'yticklabel', {'\mu' 1:length(Xmu)});
ylim([0 length(Xmu)+2]);
grid on
