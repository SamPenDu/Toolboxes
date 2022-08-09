function [Bias Uncertainty Choice BehavAccu ModelAccu] = EstimatePercBias(Stimuli, Responses, IsCorrect, DispOn, SubPlots, Feature)
%
% [Bias Uncertainty Choice BehavAccu ModelAccu] = EstimatePercBias(Stimuli, Responses, IsCorrect, [DispOn, SubPlots, Feature])
%
% Generic analysis tool for Multiple Alternatives Perceptual Search experiments. 
% 
% Inputs:
%   Stimuli:        K * N matrix with the stimulus values for each of K trials
%                    and N stimulus locations. 0 means the same as reference.
%
%   Responses:      K * 1 vector containing the responses for each of K trials,
%                    that is which stimulus location was chosen.
%
%   IsCorrect:      K * 1 vector containing 1s and 0s to defining correct trials.
%                    (If you want to use all just set all to 0!)
%
%   DispOn:         If true (default), displays the results as a figure.
%
%   SubPlots:       1 * N vector with the subplot indeces you want to use to
%                    order the subplots for each of the stimulus locations. 
%                    This defaults to 1:N if you don't define it, which may not
%                    correspond to the actual stimulus locations.
%
%   Feature:        String used as a label for the x-axes e.g. 'Size (log_2)'
%                    Defaults to 'Stimulus feature'
%
% Outputs:
%   Bias:           1 * k vector of perceptual bias estimate per location.
%   Uncertainty:    1 * k vector of perceptual uncertainty estimate per location.
%   Choice:         1 * k vector of choice frequency per location.
%   BehavAccu:      Behavioural accuracy
%   ModelAccu:      Model accuracy (goodness-of-fit)
%
% 19/04/2016 - Created this function (DSS)
% 07/06/2016 - Fixed error with outputs and help section (DSS)
%

%% Basic parameters 
N = size(Stimuli,2); % Number of locations
K = size(Stimuli,1); % Number of trials
V = range(Stimuli(:)) / 8; % Variance across all locations
% If Responses is row vector rotate it
if size(Responses,2) > 1
    Responses = Responses';
end
% If variable length mismatches
if size(Responses,1) ~= K
    error('Number of trials in response vector and stimulus matrix mismatch!');
end
% Overall performance
BehavAccu = mean(IsCorrect);

%% Determine default inputs
if nargin < 4
    DispOn = true; % Display on
    SubPlots = 1:N; % Subplot indeces  
    Feature = 'Stimulus feature'; % Independent variable
elseif nargin < 5
    SubPlots = 1:N; % Subplot indeces  
    Feature = 'Stimulus feature'; % Independent variable
elseif nargin < 6
    Feature = 'Stimulus feature'; % Independent variable
end

%% Perceptual map parameters 
sigs = -V*3 : V/20 : +V*3;
Bias = NaN(1,N);
Uncertainty = NaN(1,N);
Choice = NaN(1,N);

%% Seed parameters for optimization
for e = 1:N    
    % Calculate parameters
    Bias(e) = mean(Stimuli(Responses==e & ~IsCorrect,e)); % Peak of Gaussian
    Uncertainty(e) = std(Stimuli(Responses==e,e)); % Dispersion of Gaussian
    Choice(e) = mean(Responses==e); % Proportion this element was chosen relative to chance (log2-ratio)
end    

%% Fit forward model
pre_M_accu = 1 - errfun([Bias Uncertainty], Stimuli, Responses); % Accuracy before model fit
[fP fE] = fminsearch(@(P) errfun(P,Stimuli,Responses), [Bias Uncertainty]);
Bias = fP(1:N); % Fitted biases
Uncertainty = fP(N+1:end); % Fitted widths
ModelAccu = 1 - fE; % Model accuracy

%% Plot figure
if DispOn
    TitlStr = ['Accuracy: Behaviour = ' num2str(BehavAccu) ', Model: ' num2str(ModelAccu) ' ( Summary stats only: ' num2str(pre_M_accu) ')'];
    figure('name', TitlStr); maximize;

    % Loop thru elements
    for e = 1:N    
        % Plot figure
        subplot(2,N/2,SubPlots(e)); hold on

        % Histogram of catch trials
        [rn b] = hist(Stimuli(Responses==e & ~IsCorrect,e));
        b(rn==0) = []; rn(rn==0) = [];
        plot(b, rn/max(rn)*Choice(e), 'ko', 'markerfacecolor', 'k', 'markersize', 3, 'linestyle', 'none');
        % Smooth histogram of catch trials
        [sn b] = ksdensity(Stimuli(Responses==e & ~IsCorrect,e));
        plot(b, sn/max(sn)*Choice(e), 'k:', 'linewidth', 2);
        % Fitted distribution
        plot(sigs, gaussian(sigs, Choice(e), Bias(e), Uncertainty(e)), 'k', 'linewidth', 2);

        % Denote parameters on plot
        scatter(Bias(e), .05, 80, 'kv', 'filled', 'linewidth', 2); % Peak position
        line([0 0], [0 1], 'color', [1 1 1]/2, 'linestyle', '--', 'linewidth', 2); % Zero line
        line([-1 +1]*V*4, [1 1]/N, 'color', [1 1 1]/2, 'linestyle', '--', 'linewidth', 2); % Chance line

        % Show results in title
        title({['Bias: ' num2str(Bias(e))]; ['Uncertainty: ' num2str(Uncertainty(e))]; ['Choice: ' num2str(Choice(e))]});
        xlim([-V*3 +V*3]);
        ylim([0 max(Choice)*1.5]);

        % Cosmetic changes
        xlabel(Feature);
        ylabel('Proportion chosen');
        axis square    
    end
end

%% Predict behavioural response
function err = errfun(P, elm, rsp)

% Number of elements
N = size(elm,2);
% Detector firing per trial & element
F = NaN(size(elm));
% Loop thru elements
for e = 1:N    
    F(:,e) = gaussian(elm(:,e), 1, P(e), P(N+e));
end

% Vector of predicted responses
prsp = NaN(size(elm,1),1);
% Loop thru trials
for t = 1:size(elm,1)
    prsp(t) = find(F(t,:) == max(F(t,:)),1);
end

% Calculate prediction error
err = mean(prsp ~= rsp);

%% Gaussian function
function y = gaussian(x, beta, mu, sigma)

y = beta * exp(-((x-mu).^2 / (2*sigma.^2)));