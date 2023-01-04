function Y = rem_nan(X)
% removes NaN from correlation array

Y = X(~isnan(sum(X,2)),:);

    
        