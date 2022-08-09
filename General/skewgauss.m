function y = skewgauss(x, beta, mu, sigma, alpha) 
%
% y = skewgauss(x, beta, mu, sigma, alpha) 
%
%   Returns value y for a skewed gaussian given by coefficients
%

y = 2 * gauss(x,beta,mu,sigma) .* normcdf(x.*alpha);

