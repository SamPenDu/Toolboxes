function epsilon = SmallN_epsilon(k, n, alpha, sens, col)
%
% epsilon = SmallN_epsilon(k, n, alpha, sens, col)
%
% Plots the likelihood ratio that k successes out of n trials 
% could have occurred under the alternative hypothesis H1 
% relative to the null hypothesis H0.
%
% The probabilities alpha, the nominal false positive rate, and sens, 
% the sensitivity (1-beta, the false negative rate) of individual tests.
%
% The optional input col defines the colour of the plotted curve
%
% If no outpt argument is defined, the function also plots the evidence curve 
% of the likelihood ratio over the full range of possible sensitivities from 0-1, 
% with the sensitivity (1-beta) indicated by a symbol, reported in the title, 
% The function returns epsilon.
%
% 15/06/2023 - Written (DSS)
%

if nargin < 5
    col = 'k';
end

H0 = binopdf(k,n,alpha); % Likelihood of null hypothesis, given alpha
H1 = binopdf(k,n,sens); % Likelihood of alternative hypothesis, given 1-beta

% Likelihood ratio, given beta
epsilon = H1 / H0;
if epsilon < 20
    ndec = 3;
else
    ndec = 1;
end

% Calculate likelihood curve
AllH1s = [];
AllSens = alpha:.01:1;
for b = AllSens
	AllH1s = [AllH1s; binopdf(k,n,b)];
end
Lh_curve = AllH1s / H0;

% Plot curve?
if nargout == 0
    hold on
    plot(AllSens, Lh_curve, 'color', col, 'LineWidth', 2);
    grid on
    line([0 1], [50 50], 'color', 'k', 'LineWidth', 2, 'LineStyle', '--');
    line([0 1], 1./[50 50], 'color', 'k', 'LineWidth', 2, 'LineStyle', '--');
    line([0 1], [1 1], 'color', 'k', 'LineWidth', 2, 'LineStyle', ':');
    scatter(sens, epsilon, 50, 'MarkerEdgeColor', col, 'MarkerFaceColor','w', 'LineWidth', 2);
    scatter(alpha, 1, 50, 'k', 'filled');
    set(gca, 'fontsize', 12, 'yscale', 'log');
    xlabel('Sensitivity (1-\beta)');
    ylabel('\epsilon');
    title({ [num2str(k) ' of ' num2str(n) ' tests p < ' num2str(alpha)]; ...
            ['\epsilon = ' num2str(round(epsilon,ndec))] });
end