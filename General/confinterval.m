function ci = confinterval(X, bounds)

if nargin < 2
    bounds = 95;
end

mu = mean(X);
sigma = std(X);
f = 1 - (bounds/100);

ci = norminv([f/2, 1-f/2], mu, sigma);