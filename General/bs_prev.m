function P = bs_prev(X, DispOn)
%
% P = bs_prev(X, [DispOn=true])
%
% Bootstrapped prevalence test. Returns in P the estimated prevalence & its 95% confidence interval.
%
%   X contains the bootstrap iterations for each subject/observation in the data sample.
%    So for example if you have five subjects and bootstrapped their result 10000 times,
%    this is a 10000-by-5 matrix where each row is a bootstrap from a given subject.
%
%   DispOn toggles whether the bootstrapped prevalence distribution is plotted.
%
% 01/11/2022 - Written (DSS)
%

% Determine bootstrapped iterations in same direction as grand mean
S = sign(X) == sign(nanmean(X(:)));
% Prevalence per subject/observation 
sP = mean(S);
% Bootstrapped population prevalence distribution
bsP = bootstrp(10000, @mean, sP);
% Prevalence & confidence interval
P = [mean(sP) prctile(bsP, [2.5 97.5])];

% Plot figure?
if nargin < 2 || DispOn
    [y,x] = ksdensity(bsP);
    plot(x, y, 'k', 'linewidth', 2);
    hold on
    errorbar(P(1), max(y)/10, P(2)-P(1), P(3)-P(1), 'horizontal', ...
        'color', 'k', 'marker', 'o', 'markersize', 10, 'markerfacecolor', 'w', 'linewidth', 2);
    set(gca, 'fontsize', 12, 'xtick', 0:.25:1);
    xlabel('Population prevalence');
    ylabel('Probability density');
    xlim([0 1]);
    grid on
end
    