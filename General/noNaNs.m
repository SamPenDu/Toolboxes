function y = noNaNs(d)
% returns all non-NaN and non-Inf indeces of a matrix

y = find(~isnan(d) & ~isinf(d));
    
        