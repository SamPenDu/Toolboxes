function Power = corrpower(Rho, N, Alpha)
%
% Power = corrpower(Rho, N, [Alpha=0.05])
%
% Returns power of two-tailed correlation coefficient Rho with 
% sample size N and significance threshold Alpha (default 0.05).
% (Based on http://www.sample-size.net/correlation-sample-size)
%

if nargin == 2
    Alpha = 0.05;
end

Rho = abs(Rho);
Z_alpha = abs(norminv(Alpha/2));
C = 0.5 * log( (1+Rho) / (1-Rho) );
Power = normcdf(sqrt(N-3)*C - Z_alpha);
