function N = corrsamplesize(Rho, Power, Alpha)
%
% N = corrsamplesize(Rho, [Power=0.8, Alpha=0.05])
%
% Returns sample size N needed to test two-tailed correlation Rho with 
% significance threshold Alpha (default 0.05) and power Power (default 0.8).
% (Based on http://www.sample-size.net/correlation-sample-size)
%

if nargin == 1
    Power = 0.8;
    Alpha = 0.05;
elseif nargin == 2
    Alpha = 0.05;
end

Beta = 1 - Power;
Z_alpha = abs(norminv(Alpha/2));
Z_beta = abs(norminv(Beta));
C = 0.5 * log( (1+Rho) / (1-Rho) );
N = ((Z_alpha + Z_beta) / C)^2 + 3; 
N = round(N);

