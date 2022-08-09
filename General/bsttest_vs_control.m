function [H, P, Ci, Stats] = bsttest_vs_control(X, Y)
%
% Performs a bootstrap t-test to test that X is same as control group Y.
% This is identical to bsttest except that data are exclusively resampled 
% using the control group Y.
%
% Inputs:
%   X and Y are vectors of observations (in rows).
%
% Outputs:
%   h is a boolean indicating if the null hypothesis was rejected.
%   p is the p-value of the test.
%   ci is the 95% confidence interval of the t-distribution.
%   stats contains the field with the various statistics.
%

Xrows = size(X,1);
Yrows = size(Y,1);

% Observed t-value
[h p c s] = ttest2(X, Y);
T_obs = s.tstat;

% Bootstrap t-distribution
Ts = []; 
for shu = 1:1000
    % Both groups are resampled using data from Y
    nX = ceil(rand(Xrows,1)*Yrows); 
    nY = ceil(rand(Yrows,1)*Yrows);
    Xs = Y(nX);
    Ys = Y(nY);
    [h p c s] = ttest2(Xs, Ys);
    Ts = [Ts; s.tstat];
end

% P-values
P = mean(abs(Ts) > abs(T_obs));     % Two-tailed test (X=Y)
P_left = mean(Ts < T_obs);     % One-tailed test (X<Y)
P_right = mean(Ts > T_obs);     % One-tailed test (X>Y)

% Condidence interval
Ci = prctile(Ts, [2.5 97.5]);
if size(Ci,1) == 1
    Ci = Ci';
end
% Null hypothesis rejected?
H = P < 0.05;

% Stats output
Stats = struct;
Stats.df = s.df;
Stats.tstat = T_obs;
Stats.pstat = P;
Stats.pl = P_left;
Stats.pr = P_right;
Stats.bstdist = Ts;

