function P = pctscore(X)
%
% Returns the percentile score for each value in X (relative to its column).
% (Percentile equivalent of z-score transformation)
%

nc = size(X,2);
nr = size(X,1);
P = [];

for c = 1:nc
    cP = [];
    for r = 1:nr
        cP = [cP; mean(X(:,c)<X(r,c))*100];
    end
    P = [P cP];
end