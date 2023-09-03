function Ds = EuclideanDistMat(XY)
%
% Ds = EuclideanDistMat(XY)
%
% Returns a Euclidean distance matrix between all the points in XY.
% This is a N x 2 vector of X and Y positions.
% 
% The matrix Ds returns the distance from each point to all the others.
%

N = size(XY,1); % Number of coordinates
Ds = []; % Distance matrix

% Loop thru each positions
for r = 1:N
    % Loop thru all positions
    for c = 1:N
        Ds(r,c) = sqrt(sum((XY(r,:)-XY(c,:)).^2));
    end
end
