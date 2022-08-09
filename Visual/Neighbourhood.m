function [neighbours, sorted_distm, indexes] = Neighbourhood(xy, m)
%[neighbours, sorted_distm, indexes]  = Neighbourhood(xy, m)
%
% Finds nearest, second & third nearest neighbours to a coordinate.
%
% Parameters:
%   xy :    Coordinate used as reference
%   m :     String matrix of coordinates to search
%
% Returns a 3 x 2 matrix. The columns are x and y coordinates.
% Rows contain the nearest, second, and third nearest positions.
% If m has less than 3 coordinates some are identical.
%
% Additional outputs are the list of distances to the neighbours,
% and the indeces of neighbours ranked by distance.
%

%array with distances
sz = size(m);
distm = zeros(sz(1), 1); 
for i = 1 : sz(1)
    distm(i) = norm(m(i,:) - xy(:)');
end

%sorting neighbours
[sorted_distm indexes] = sort(distm);    %sort in ascending order
d_nearest = sorted_distm(1);     %nearest distance (or same)

switch sz(1)
    case 1
        d_second = d_nearest;           %second nearest distance
        d_third = d_nearest;            %third nearest distance
    case 2
        d_second = sorted_distm(2);     %second nearest distance
        d_third = sorted_distm(2);      %third nearest distance
    otherwise    
        d_second = sorted_distm(2);     %second nearest distance
        d_third = sorted_distm(3);      %third nearest distance
end

%nearest neighbours
nearest = m(find(distm == d_nearest), :);
second = m(find(distm == d_second), :);
third = m(find(distm == d_third), :);

neighbours = [nearest; second; third];
