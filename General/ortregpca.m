function [F Rsq C] = ortregpca(X,Y)
% Using PCA for orthogonal regression

% Ensure inputs are column vectors
if size(X,1) == 1
    X = X';
end
if size(Y,1) == 1
    Y = Y';
end

% Principal component analysis
[C,tXY] = pca([X Y]);
% Determine variance explained
Rsq = 1 - sum(tXY(:,2).^2) / sum(Y.^2);
% Orthogonal regression function
F = (C(1,1)*std(Y)) / (C(2,1)*std(X));
F = [F, F * -mean(X) + mean(Y)];
