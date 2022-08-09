function [Bias, Width, Threshold, RespBias, Ps, Ws, F_Psych, F_Weibull] = AnalyseMatchingTask(Stimuli, Choices)
%
% [Bias, Width, Threshold, RespBias, Ps, Ws, F_Psych, F_Weibull] = AnalyseMatchingTask(Stimuli, Choices)
%
% Estimates perceptual bias & sensitivity from 2-candidate matching task:
%   Stimuli: n-by=2 matrix with the two stimuli for n trials
%   Choices: Which stimulus was chosen on each trial (1 or 2)
%
% Returns the following output variables:
%   Bias:       50% threshold of psychometric curve
%   Width:      Bandwidth (1/sensitivity) of psychometric curve
%   Threshold:  Threshold level of Weibull function on distances
%   RespBias:   Response bias = Overall proportion stimulus 2 was chosen
%   Ps:         Psychometric function data with bins, proportion chosen, and number of trials in colums
%   Ws:         Weibull function data with bins, proportion chosen, and number of trials in colums
%   F_Psych:    Psychometric function fit data structure
%   F_Weibull:  Weibull function fit data structure
%

%% Tranform data
% Transform choices into binary
Choices = Choices == 2;

% Tranform stimulus space
Means = mean(Stimuli,2); % Mean of stimuli
Diffs = Stimuli(:,1) - Stimuli(:,2); % Difference between stimuli
Dists = abs(Diffs);

% Combine choices relative to zero
Rel2Zero = Choices;
Rel2Zero(Diffs < 0) = ~Rel2Zero(Diffs < 0);

% Collapse across distances & bin on mean
Ps = [];
for b = min(Means):range(Means)/9:max(Means)
    x = Means > b-range(Means)/18 & Means <= b+range(Means)/18;
    Ps = [Ps; b mean(Rel2Zero(x)) sum(x)];
end

% Collapse across means & bin on distances 
Ws = [];
for b = min(Dists):range(Dists)/6:max(Dists)
    x = Dists > b-range(Dists)/12 & Dists <= b+range(Dists)/12;
    Ws = [Ws; b mean(~Rel2Zero(x)) sum(x)];
end

%% Fit psychometric curve & outputs
RespBias = mean(Choices); % Response bias
% Psychometric function
F_Psych = FitPsychFunc(Ps(:,1), Ps(:,2:3), true);
Bias = F_Psych.threshold; % PSE
Width = F_Psych.bandwidth; % Uncertainty of curve
% Weibull function
F_Weibull = FitWeibullFunc(Ws(:,1), Ws(:,2:3), 0.5);
Threshold = F_Weibull.threshold; % Weibull threshold (sensitivity)

%% Open figure?
if nargout == 0
    figure; maximize

    % Psychomatrix 
    subplot(2,3,1);
    scatter(Stimuli(:,1), Stimuli(:,2), 50, Choices, 'filled');
    colormap([1 0 0; 0 0 1]);
    set(gca, 'fontsize', 20);
    xlabel('S_1');
    ylabel('S_2');
    title('Psychomatrix');
    axis square
    x = xlim;
    y = ylim;
    a = [min([x y]) max([x y])];
    hold on
    line(a, a, 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', ':');
    line(a, a.*-1, 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', ':');

    % Transformed
    subplot(2,3,2);
    scatter(Means, Diffs, 50, Choices, 'filled');
    colormap([1 0 0; 0 0 1]);
    set(gca, 'fontsize', 20);
    xlabel('(S_1 + S_2) / 2');
    ylabel('S_1 - S_2');
    title('Transformed');
    axis square
    x = xlim;
    y = ylim;
    a = [min([x y]) max([x y])];
    hold on
    line([0 0], ylim, 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', '--');
    line(xlim, [0 0], 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', '--');

    % Combined
    subplot(2,3,3);
    scatter(Means, Dists, 50, Rel2Zero, 'filled');
    colormap([1 0 0; 0 0 1]);
    set(gca, 'fontsize', 20);
    xlabel('(S_1 + S_2) / 2');
    ylabel('|S_1 - S_2|');
    title('Combined');
    axis square
    x = xlim;
    y = ylim;
    a = [min([x y]) max([x y])];
    hold on
    line([0 0], ylim, 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', '--');
    line(xlim, [0 0], 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', '--');

    % Psychometric curve
    subplot(2,2,3); hold on
    scatter(Ps(:,1), Ps(:,2), Ps(:,3)*10+1, [.5 .5 .5], 'filled', 'markeredgecolor', 'k');
    xl = xlim;
    line([1 1]*F_Psych.threshold, [0 .5], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
    line(xlim, [.5 .5], 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', '--');
    PlotPsychFunc(xl(1):range(xl)/100:xl(2), F_Psych, 'r', 2);
    set(gca, 'fontsize', 20);
    xlabel('(S_1 + S_2) / 2');
    ylabel('P_{min was chosen}');
    title('Psychometric function');

    subplot(2,2,4); hold on
    scatter(Ws(:,1), Ws(:,2), Ws(:,3)*10+1, [.5 .5 .5], 'filled', 'markeredgecolor', 'k');
    xl = xlim;
    line([1 1]*F_Weibull.threshold, [0 F_Weibull.function(F_Weibull.threshold)], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
    line(xlim, [.5 .5], 'color', [.5 .5 .5], 'linewidth', 2, 'linestyle', '--');
    PlotPsychFunc(xl(1):range(xl)/100:xl(2), F_Weibull, 'r', 2);
    set(gca, 'fontsize', 20);
    xlabel('|S_1 - S_2|');
    ylabel('P_{max was chosen}');
    title('Weibull function');
end