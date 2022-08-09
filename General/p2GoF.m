function R2 = p2GoF(p, Nobs, Npar)
% Converts the p-value P into a goodness-of-fit R^2 value. 
% Requires the number of observations Nobs and number of free parameters Npar.

R2 = t2r(t_value(p, Nobs-(Npar+1)), Nobs)^2;
