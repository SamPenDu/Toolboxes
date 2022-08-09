function p = FalsePos(n, lambda, r, alpha, ct)
%
%p = FalsePos(n, [lambda = '1.*randn(n,1)'], [r = 1000], [alpha = 0.05], [ct = 'p'])
%
% Determines the false positive rate for correlations between two samples.
% n is the sample size. lambda is a string describing the function introducing conditional variance. 
% Thus to ensure a homoscedastic data sample, set this to '1.*randn(n,1)'. To introduce heteroscedasticity 
% set this to a function of x, e.g. 'x.^2.*randn(n,1)'. r is the number of repetitions. alpha is the alpha level. 
% ct is the type of correlation to be used.
%
% p returns the false positive probability.
%

if nargin < 2
    lambda = '1';
    r = 1000;
    alpha = 0.05;
    ct = 'p';
elseif nargin < 3
    r = 1000;
    alpha = 0.05;
    ct = 'p';
elseif nargin < 4
    alpha = 0.05;
    ct = 'p';
elseif nargin < 5
    ct = 'p';
end

if lower(ct) == 'p'
    ct = 'pearson';
elseif lower(ct) == 's'
    ct = 'spearman';
elseif lower(ct) == 'k'
    ct = 'kendall';
end

ps=[]; 
for i=1:r
    % Randomize new data set
    x = randn(n,1);
    y = eval(lambda);
    % Correlation 
    if ct == 'w'
        [br bp] = pbcorr(x,y,0.2);
    else
        [br bp] = corr(x,y,'type',ct); 
    end
    ps = [ps; bp]; 
    disp(i); 
end
p = mean(ps < 0.05);
