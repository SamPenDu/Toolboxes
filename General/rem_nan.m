function y = rem_nan(d)
% removes NaN from correlation array

y = [];

for i = 1 : size(d,1)
    if ~isnan(d(i,:))
        y = [y; d(i,:)];
    end
end

    
        