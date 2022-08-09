function y = unitize(x)
% Normalizes the data in x so it is between 0 and 1.

x = x - nanmin(x);
y = x / nanmax(x);