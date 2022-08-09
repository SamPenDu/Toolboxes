function errmat = logsem(data)
% Calculates the logarithmic standard error for the data.

ldat = log(data);
mdat = mean(ldat);

err = sem(ldat);

upperr = mdat + err;
lowerr = mdat - err;

upperr = exp(upperr);
lowerr = exp(lowerr);

errmat = [upperr; lowerr];