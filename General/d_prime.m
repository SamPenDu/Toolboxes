function [dp rb ct] = d_prime(pH, pFA)
% [dp rb ct] = d_prime(pH, pFA)
%
% Returns d-prime for given hit rate and false alarms:  z(pH)-z(pFA)
% Second argument returns the response bias:    (z(pH)+z(pFA))/2
% Third argument returns the criterion:     -z(pFA)

if pH == 1
    pH = 0.9999;
end
if pFA == 0
    pFA = 0.0001;
end

dp = norminv(pH) - norminv(pFA);
rb = (norminv(pH) + norminv(pFA)) / 2;
ct = -norminv(pFA);