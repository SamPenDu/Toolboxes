function D = sam_mahal(Y,X)
% 
% D = sam_mahal(Y,X)
%
% Inefficient home-made version of mahal function.

D = []; 
mu = mean(X);
sigma = cov(X);
for i = 1:size(Y,1)
    D(i) = (Y(i,:)-mu)*inv(sigma)*(Y(i,:)-mu)';
end