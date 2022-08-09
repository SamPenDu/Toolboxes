function mdist = delauniate(csv)
%mdist = delauniate(csv)
% Returns the mean distance of elements in stimulus array csv
% to the most central element with index elem.

eccs = [];
for i = 1 : size(csv,1)
    eccs = [eccs; norm(csv(i,2:3))];
end
elem = find(eccs == min(eccs));
elem = elem(1);

xy = [];
for i = 1 : size(csv,1)
    try xy = [xy; csv(i,2:3) - csv(elem,2:3)]; catch keyboard; end
end

tri = delaunay(xy(:,1), xy(:,2));

% triplot(tri, xy(:,1), xy(:,2));
% hold on;
% scatter(xy(:,1), xy(:,2));
% scatter(xy(elem,1), xy(elem,2), 'filled', 'r');

dists = [];
for i = 1 : size(tri,1)
    ctri = tri(i,:);
    n = find(ctri ~= elem);
    if length(n) < 3
        dists = [dists; norm(xy(ctri(n(1)))); norm(xy(ctri(n(2))))];
%         scatter(xy(ctri(n(1)),1), xy(ctri(n(1)),2), 'filled', 'k');
%         scatter(xy(ctri(n(2)),1), xy(ctri(n(2)),2), 'filled', 'k');
    end
end

mdist = mean(unique(dists));
