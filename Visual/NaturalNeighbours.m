function nnb = NaturalNeighbours(xy, tri, v)
%nnb = NaturalNeighbours(xy, tri, v)
%
% Returns vertex coordinates of natural neighbors of vertex index v.
% xy contains the vertex coordinates, tri is their Delaunay tesselation.

% indeces of triangles containing the vertex
t = [find(tri(:,1) == v); find(tri(:,2) == v); find(tri(:,3) == v)];

% indeces of verteces
ts = tri(t,:);

% nearest natural neighbours
nnb = [xy(ts(:,1),1), xy(ts(:,1),2); ...
       xy(ts(:,2),1), xy(ts(:,2),2); ... 
       xy(ts(:,3),1), xy(ts(:,3),2)];

% remove duplicates 
nnb = UniqueRows(nnb);