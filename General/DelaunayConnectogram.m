function Groups = DelaunayConnectogram(x,y)
%
% Groups = DelaunayConnectogram(x,y)
%
% Returns the groups for PlotConstellations to describe the connectogram
% defined by a Delaunay tesselation of the points in x and y.
%

N = length(x); % Number of nodes
Groups = {}; % Output groups
for i = 1:N
    Groups{i,1} = [];
end

% Triangles of Delaunay tesselation
Triangles = delaunay(x,y); 

% Loop thru nodes
for i = 1:N
    % Loop thru triangles
    for j = 1:size(Triangles,1)
        ct = Triangles(j,:) == i; % Vertices in current triangle
        if sum(ct,2) == 1
            Groups{i} = [Groups{i} Triangles(j,ct==0)]; 
        end
    end
    % Remove redundancies
    Groups{i} = unique(Groups{i});
end
