function F = FitWeibullFunc(x,y,b)
%
% F = FitWeibullFunc(x,y,b)
%
%   Fits a cumulative Weibull psychometric function with baseline b:
%       x is a vector with the values of the independent variable
%       y is a vector of the proportion correct.
%       Optionally, y can also have a second column with weights for a robust fit.
%
%   Returns struct F which contains the following fields:
%       threshold (fitted: shift parameter)
%       bandwidth (fitted: slope parameter)
%       amplitude (fitted: asymptote parameter)
%       baseline (fixed: b)
%       rsquare of the curve fit 
%       x is original x data vector
%
%   11/03/2014 - added exhaustive grid search for seed parameters (DSS)
%   17/08/2015 - fixed a bug with too many output variables (DSS)
%   22/04/2020 - added option to weight points by number of trials (DSS)
%

% Exhaustive grid search
CurMin = Inf; % Current minimum
CurThr = 0; % Threshold at current minimum
CurBwd = 1; % Bandwidth at current minimum
for src_thr = min(x):range(x)/50:max(x)
    for src_bwd = range(x)/50:range(x)/50:range(x)/2
        err = errfun([src_thr src_bwd 1-b], x, y, b);
        if err < CurMin
            % Update current parameters
            CurMin = err; 
            CurThr = src_thr;
            CurBwd = src_bwd;
        end
    end
end

% Fit the curve
[f,r] = fminsearch(@(p)errfun(p,x,y,b), [CurThr CurBwd 1-b], optimset('Display','off'));

% Return parameters
F = struct;
F.threshold = f(1);
F.bandwidth = f(2);
F.amplitude = f(3);
F.baseline = b;
F.rsquare = 1 - r/sum((y(:,1)-mean(y(:,1))).^2);
F.function = @(x) psyfun(x,f(1),f(2),f(3),b);

%% Internal functions

function r = errfun(p,x,y,b)
% Error function
if size(y,2) == 1
    y = [y ones(size(y))]; % Weight all points equally if none defined
end
f = psyfun(x, p(1), p(2), p(3), b);
if p(3) > 1
    r = 1;
else
    r = sum((f-y(:,1)).^2 .* y(:,2));
end

function y = psyfun(x,c,s,a,b)
% Cumulative Weibull function
%   c=centroid, s=scale, a=amplitude, b=baseline
y = b + wblcdf(x,c,s)*a;
