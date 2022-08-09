function y = gauss(x, beta, mu, sigma)
%
% y = gauss(x, beta, mu, sigma)
%
%   Returns value y for gaussian given by coefficients
%

y = beta * exp(-((x-mu).^2 / (2*sigma.^2)));
