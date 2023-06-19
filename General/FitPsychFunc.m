function F = FitPsychFunc(x,y,FixAmp)
%
% F = FitPsychFunc(x,y,[FixAmp=NaN])
%
%   Fits a cumulative Gaussian psychometric function centred on y=0.5:
%       x is a vector with the values of the independent variable
%       y is a vector of the choice probability 
%           Optionally, y can also have a second column with weights for a robust fit
%       FixAmp is a scalar to define if the amplitude is fixed
%           If left undefined, this defaults to NaN which means the amplitude is a free parameter
%           Setting this to 1 would mean the curve spans the whole range from 0-1
%
%   Returns struct F which contains the following fields:
%       threshold (fitted: centroid of gaussian)
%       bandwidth (fitted: width of gaussian)
%       amplitude (fitted: asymptote on each end) - if not fixed!
%       baseline (fixed: (1-amplitude)/2)
%       rsquare of the curve fit 
%       x is original x data vector
%
%   11/03/2014 - added exhaustive grid search for seed parameters (DSS)
%   17/08/2015 - fixed a bug with too many output variables (DSS)
%   22/04/2020 - added option to weight points by number of trials (DSS)
%   24/04/2020 - added option to fix the amplitude (DSS)
%

% Amplitude defaults to free parameter
if nargin < 3
    FixAmp = NaN;
end

% Exhaustive grid search
CurMin = Inf; % Current minimum
CurThr = 0; % Threshold at current minimum
CurBwd = 1; % Bandwidth at current minimum
for src_thr = min(x):range(x)/50:max(x)
    for src_bwd = range(x)/50:range(x)/50:range(x)/2
        err = errfun([src_thr src_bwd 1], x, y, FixAmp);
        if err < CurMin
            % Update current parameters
            CurMin = err; 
            CurThr = src_thr;
            CurBwd = src_bwd;
        end
    end
end

% Fit the curve
if isnan(FixAmp)
    % Amplitude is free parameter
    [f,r] = fminsearch(@(p)errfun(p,x,y), [CurThr CurBwd 1], optimset('Display','off'));
else
    % Amplitude is fixed
    [f,r] = fminsearch(@(p)errfun(p,x,y,FixAmp), [CurThr CurBwd], optimset('Display','off'));
    f(3) = FixAmp;
end

% Return parameters
F = struct;
F.threshold = f(1);
F.bandwidth = f(2);
F.amplitude = f(3);
F.baseline = (1-f(3))/2;
F.rsquare = 1 - r/sum((y(:,1)-mean(y(:,1))).^2);
F.function = @(x) psyfun(x,f(1),f(2),f(3));

%% Internal functions

function r = errfun(p,x,y,FixAmp)
% Error function

% If amplitude not fixed
if nargin < 4
    FixAmp = NaN;
end

% Weight all points equally if none defined
if size(y,2) == 1
    y = [y ones(size(y))]; 
end
if isnan(FixAmp)
    % Amplitude is a free parameter
    f = psyfun(x, p(1), p(2), p(3));
else
    % Amplitude is fixed
    f = psyfun(x, p(1), p(2), FixAmp);
end
if isnan(FixAmp)&& p(3) > 1
    r = 1;
else
    r = sum((f-y(:,1)).^2 .* y(:,2)) / sum(y(:,2));
end

function y = psyfun(x,c,s,a)
% Cumulative Gaussian function
%   c=centroid, s=sigma, a=amplitude
y = (0.5*(1 + erf((x-c)/(sqrt(2)*s)))) * a + (1-a)/2;
