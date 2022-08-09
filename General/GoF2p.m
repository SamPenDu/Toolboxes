function p = GoF2p(R2, Nobs, Npar)
% Converts the goodness-of-fit R2 into a p-value. 
% Requires the number of observations Nobs and number of free parameters Npar.

p = p_value(r2t(sqrt(R2), Nobs), Nobs-(Npar+1));
