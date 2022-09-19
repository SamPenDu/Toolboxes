function Y = foldovermat(X)
%
% Folds matrix X over the identity diagonal & averages the folded cells.
% Use this for similarity matrices with non-redundant variables.
% Since cells are averaged you may wish to z-transform them first.

Y = zeros(size(X)); 
for r = 1:size(X,1) 
    for c = 0:r 
        if c > 0 
            Y(c,r) = mean([X(r,c) X(c,r)]); 
        end
    end
end
Y(isnan(Y)) = 0;
