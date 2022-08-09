function tris = trifind(tri, v)
%tris = trifind(tri, v)
% Returns the triangles in tri which contain vertex v.
%

% indeces of triangles containing the vertex
t = [find(tri(:,1) == v); find(tri(:,2) == v); find(tri(:,3) == v)];

% indeces of verteces
tris = tri(t,:);
