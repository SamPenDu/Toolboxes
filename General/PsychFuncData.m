function [X,Y,W] = PsychFuncData(S, R, isResampled)
%
% [X,Y,W] = PsychFuncData(S, R, [isResampled=false])
% 
% Generates the input data for a psychometric curve fit. 
%   S is a vector with the stimulus values for each trial.
%   R is a corresponding vector for the response in each trials.
%       For a threshold measurement, this is correct vs incorrect.
%       For a PSE measurement, this is test chosen or not chosen.
%   isResampled is optional boolean to toggle resampling of responses.
%
% Each row in the output vectors is a stimulus level:
%   X contains the unique stimulus levels.
%   Y contains the corresponding response probabilities.
%   W contains weights based on the proportion of trials. 
%   

if nargin < 3
    isResampled = false;
end

X = unique(S); % Unique stimuli
Y = NaN(size(X)); % Proportion chosen
W = NaN(size(X)); % Weights based on number of trials
if size(X,1) == 1
    X = X';
end

% Loop thru stimulus levels
for i = 1:length(X)
    cR = R(S==X(i)); % Current responses
    if isResampled
        % Resampling responses for bootstrap
        cR = cR(randi(length(cR),1,length(cR)));
    end
    Y(i) = mean(cR); % Mean of current responses
    W(i) = mean(S==X(i));
end

% Calculate weights
W = W / max(W);