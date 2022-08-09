function [cp cis acis] = CoverageProb(n, lambda, b, r, ct)
%
%[cp cis acis] = CoverageProb(n, [lambda = '1.*randn(n,1)'], [b = 10000], [r = 1000], [ct = 'p'])
%
% Determines coverage probability for bootstrapped correlations between two samples.
% n is the sample size. lambda is a string describing the function introducing conditional variance. 
% Thus to ensure a homoscedastic data sample, set this to '1.*randn(n,1)'. To introduce heteroscedasticity 
% set this to a function of x, e.g. 'x.^2.*randn(n,1)'. b is the number of bootstrap samples. r is the number of repetitions.
% ct defines the type of correlation to be run.
%
% cp returns the coverage probability, cis contains the repeated confidence intervals. 
% acis contains the adjusted confidence intervals (only works for 599 bootstraps).
%

if nargin < 2
    lambda = '1.* randn(n,1)';
    b = 10000;
    r = 1000;
    ct = 'p';
elseif nargin < 3
    b = 10000;
    r = 1000;
    ct = 'p';
elseif nargin < 4
    r = 1000;
    ct = 'p';
elseif nargin < 5
    ct = 'p';
end

cis=[]; acis = [];
for i=1:r
    % Randomize new data set
    x = randn(n,1);
    y = eval(lambda);
    % Bootstrap confidence interval
    br=bscorr(x,y,b,ct); 
    c=prctile(br,[2.5 97.5]); 
    cis=[cis; c]; 
    if b == 599
        brs = sort(br);
        acis = [acis; brs(7) brs(593)];
    end
    disp(['#' n2s(i) ': ' lambda ', B =' n2s(b)]); 
end
cp = mean(cis(:,1)<0 & 0<cis(:,2));

new_line;
