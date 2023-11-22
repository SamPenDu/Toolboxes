function F = FitGaussian(x,y,FixAmp)
%
% F = FitGaussian(x,y,[FixAmp=NaN])
%
%   Fits a Gaussian function for matching error rates 
%       x is a vector with the values of the independent variable
%       y is a vector of the choice probability 
%           Optionally, y can also have a second column with weights for a robust fit
%       FixAmp is a scalar to define if the amplitude is fixed
%           If left undefined, this defaults to NaN which means the amplitude is a free parameter
%           Setting this to 1 would mean the curve spans the whole range from 0-1
%
%   Returns struct F which contains the following fields:
%       centroid (fitted: centroid of gaussian)
%       bandwidth (fitted: width of gaussian)
%       amplitude (fitted: asymptote on each end) - if not fixed!
%       rsquare of the curve fit 
%       function is the fitted function
%       x & y are the input data
%
%   05/11/2023 - Adapted from FitPsychFun (DSS)
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
F.centroid = f(1);
F.bandwidth = f(2);
F.amplitude = f(3);
F.baseline = (1-f(3))/2;
F.rsquare = 1 - r/sum((y(:,1)-mean(y(:,1))).^2);
F.function = @(x) gaussian(x,f(1),f(2),f(3));
F.x = x;
F.y = y;

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
    f = gaussian(x, p(1), p(2), p(3));
else
    % Amplitude is fixed
    f = gaussian(x, p(1), p(2), FixAmp);
end
if isnan(FixAmp)&& p(3) > 1 || p(3) < 0.5
    r = 1;
else
    r = sum((f-y(:,1)).^2 .* y(:,2)) / sum(y(:,2));
end

function y = gaussian(x,c,s,a)
% Cumulative Gaussian function
%   c=centroid, s=sigma, a=amplitude
y = a * exp(-((x-c).^2 / (2*s.^2)));
