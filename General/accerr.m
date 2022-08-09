function err = accerr(accu, num)
% Returns the estimated error for accuracy accu when there are num trials.

err = sqrt(accu*(1-accu)/(num-1));