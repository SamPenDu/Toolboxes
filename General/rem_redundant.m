function y = rem_redundant(x)
% removes redundant rows from a matrix 

y = x(1,:);

for i = 2:size(x,1)
    d = sum(abs(y-repmat(x(i,:), size(y,1), 1)), 2);   % Residuals of difference
    r = d==0;  % Find redundant rows
    if sum(r) == 0
        y = [y; x(i,:)];
    end
end

    
        