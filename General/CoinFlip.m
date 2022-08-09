function x = CoinFlip(n, p)
% x = CoinFlip(n, p)
%
% Generate a list x of zeros and ones according to coin flipping 
% (i.e. Bernoulli) statistics with probability p of getting a 1.
%

% Generate n random variables on the real interval [0,1]).
x = rand(n,1) < p;



