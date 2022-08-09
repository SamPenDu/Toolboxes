function err = bserr(X)

rows = size(X,1);
cols = size(X,2);

Y = [];
for s = 1:1000
    n = ceil(rand(rows,cols)*rows);
    y = X(n);
    Y = [Y; mean(y)];
end
err = std(Y);