function D = kdist(Y, X, k)
% 
% D = kdist(Y, X, [k=3])
%
% Calculates the multivariate distances of each point in Y from the sample X.
% This is the mean of the k minimal Euclidian distances to all the points in X.

if nargin < 3
    k = 3;
end

D = NaN(size(Y,1),1); 
for h = 1:size(Y,1)
    cD = NaN(size(X,1),1);
    for i = 1:size(X,1)
        ss = 0;
        for j = 1:size(X,2)
            ss = ss + (X(i,j)-Y(h,j)).^2;
        end
        cD(i) = sqrt(ss);
    end    
    cD = sort(cD,'ascend');
    if cD(1) == 0
        cD = cD(2:end);
    end
    D(h) = mean(cD(1:k));
end