function SimulStaircase(UpDown, N, Slope, Shift)
%SimulStaircase(UpDown, [N, Slope, Shift])
%
% Simulates the outcome of an UpDown staircase with N trials. 
%
% Parameters:
%   UpDown :    Vector describing the staircase parameters, e.g.
%                   [2 1] = 2-right/1-wrong or [3 2] = 3-right/2-wrong
%   N :         Number of trials to run (default = 1000)
%   Slope :     Slope of the psychometric curve (default = 10)
%   Shift :     Rightwards shift of the curve (default = 0.5)
%

if nargin < 2
    N = 1000;
    Slope = 10;
    Shift = 0.5;
elseif nargin < 3
    Slope = 10;
    Shift = 0.5;
elseif nargin < 4    
    Shift = 0.5;
end

% Setup basic staircase
S = SetupStaircase(1, 11, [1 11], UpDown);
Reversals = [];

% Underlying psychometric function
x = 0:0.1:1;
y = 1 ./ (1+exp((-x+Shift)*Slope))/2 + 0.5;

% Simulate trials
for t = 1:N    
    sgn = S.Signal;
    IsCorrect = rand < y(sgn);    
    S = StaircaseTrial(1, S, IsCorrect);
    [S IsRev] = UpdateStaircase(1, S, -1);
    if IsRev
        Reversals = [Reversals; t y(sgn) x(sgn)];
    end
end

% Plot psychometric curve
subplot(1,2,1);
plot(x,y); hold on
ylim([0.45 1.05]);
xlabel('Signal');
ylabel('Response');
line(xlim, [S.Accuracy S.Accuracy], 'color', 'r', 'linestyle', '--');
line(xlim, [mean(Reversals(:,2)) mean(Reversals(:,2))], 'color', 'r', 'linestyle', ':');
line([mean(Reversals(:,3)) mean(Reversals(:,3))], ylim, 'color', 'r', 'linestyle', '--');
title('Underlying psychometric curve');
legend({'Curve' 'Predicted' 'Converged'}, 'Location', 'SouthEast');

% Plot reversals
subplot(1,2,2);
plot(Reversals(:,1), Reversals(:,3)); hold on
line(xlim, [mean(Reversals(:,3)) mean(Reversals(:,3))], 'color', 'r', 'linestyle', ':');
title({['Predicted accuracy: ' n2s(S.Accuracy) '%']; ...
       ['Converged on: ' n2s(mean(Reversals(:,2))) '%']; ...
       ['Threshold: ' n2s(mean(Reversals(:,3)))]});
ylim([0 1]);
xlabel('Trial #');
ylabel('Signal at reversals');

set(gcf, 'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.6]);