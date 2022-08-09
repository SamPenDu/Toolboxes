function [t,r] = wsvcorr(A, B, DispOn, cm)
%
% [t,r] = wsvcorr(A, B, [DispOn=false, cm])
%
% Calculates a Pearson's correlations with more than one data point per subject 
% DispOn toggles scatter plots. The final input defines the colour map to encode individuals. 
%
% Inputs A and B are matrices with a row per subject and a column per within-subject measurement. 
%
% The output t is the result of a t-test vs 0 across the z-transformed correlations. It is a 2x4 matrix containing in columns: 
%   (1) the average correlation R_mu, (2) the t-statistic, (2) p-value and (3) degrees of freedom for the t-test 
% The first row is the raw correlation. The second row is the correlation after removing the between-subject pattern across observations.
%
% The output r is a 2x2 vector with two correlation results. Each row is: 
%  (1) Between-subject correlation (averaged across observations within each subject)
%  (2) Average within-subject correlation (averaged across subjects)
% The first columnn is the correlation coefficient, the second the p-value. 
%

if nargin < 3
    DispOn = false;
    cm = 'jet';
elseif nargin < 4
    cm = 'jet';
end

% Subjects & variables
ns = size(A,1); % Number of subjects

% Basic correlations 
[r_wsv,p_wsv] = corr(mean(A,1)', mean(B,1)'); % Averaged within-subject correlation
[r_bsv,p_bsv] = corr(mean(A,2), mean(B,2)); % Between-subject correlation 

% Within subject correlations
z = diag(atanh(corr(A',B')));
% Classical t-test
[~,p,~,ts] = ttest(z, 0);
t = [tanh(mean(z)) ts.tstat p ts.df];

% Mean corrected within subject correlations 
mA = A-repmat(mean(A,1),ns,1);
mB = B-repmat(mean(B,1),ns,1);
z = diag(atanh(corr(mA',mB')));
% Classical t-test
[~,p,~,ts] = ttest(z, 0);
t = [t; tanh(mean(z)) ts.tstat p ts.df];

% Correlation & significance 
r = [r_wsv p_wsv; r_bsv p_bsv];

% Plot data?
if DispOn 
    maximize
    cm = eval([cm '(' num2str(ns) ')']);
    
    % Within subject correlation
    subplot(2,2,1);
    hold on
    % Loop thru within-subject regressions
    for s = 1:ns
        f = polyfit(A(s,:), B(s,:), 1);
        line([min(A(s,:)) max(A(s,:))], [min(A(s,:)) max(A(s,:))] * f(1) + f(2), 'color', cm(s,:), 'linewidth', 2);
    end   
    % Loop thru scatter plots 
    for s = 1:ns
        h = scatter(A(s,:), B(s,:), 70, cm(s,:), 'filled');
        alpha(h,.5);
    end
    axis square
    title(['R_{\mu} = ' sprintf('%1.2f',t(1,1)) ', t(' num2str(t(1,4)) ') = ' sprintf('%1.2f',t(1,2)) ', p = ' sprintf('%1.3f',t(1,3))]); 

    % Within subject correlation corrected by average pattern
    subplot(2,2,2);
    hold on
    % Loop thru within-subject regressions
    for s = 1:ns
        f = polyfit(mA(s,:), mB(s,:), 1);
        line([min(mA(s,:)) max(mA(s,:))], [min(mA(s,:)) max(mA(s,:))] * f(1) + f(2), 'color', cm(s,:), 'linewidth', 2);
    end   
    % Loop thru scatter plots 
    for s = 1:ns
        h = scatter(mA(s,:), mB(s,:), 70, cm(s,:), 'filled');
        alpha(h,.5);
    end
    axis square    
    title(['R_{\psi} = ' sprintf('%1.2f',t(2,1)) ', t(' num2str(t(2,4)) ') = ' sprintf('%1.2f',t(2,2)) ', p = ' sprintf('%1.3f',t(2,3))]);
    
    % Averaged within subject correlation
    subplot(2,2,3);
    hold on
    scatter(mean(A,1)', mean(B,1)', 70, 'ko', 'filled');
    f = polyfit(mean(A,1)', mean(B,1)', 1);
    line([min(mean(A,1)) max(mean(A,1))], [min(mean(A,1)) max(mean(A,1))] * f(1) + f(2), 'color', 'k', 'linewidth', 2);
    axis square
    title(['R_W = ' sprintf('%1.2f',r(1,1)) ', p_W = ' sprintf('%1.3f',r(1,2))]); 
    
    % Between subject correlation
    subplot(2,2,4);
    hold on
    scatter(mean(A,2), mean(B,2), 70, 'ko', 'filled');
    f = polyfit(mean(A,2), mean(B,2), 1);
    line([min(mean(A,2)) max(mean(A,2))], [min(mean(A,2)) max(mean(A,2))] * f(1) + f(2), 'color', 'k', 'linewidth', 2);   
    axis square 
    title(['R_B = ' sprintf('%1.2f',r(2,1)) ', p_B = ' sprintf('%1.3f',r(2,2))]); 
end

