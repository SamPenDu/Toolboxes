function xy = Hexagon(radius)
%xy = Hexagon(radius)
%
% Generates string of coordinates for a hexagonal with radius centred on origin.
%

xy = [];

%hexagonal vertices
hexpts = [];
for theta = 0 : 60 : 360
    [hx hy] = pol2cart(theta/180*pi, radius);
    hexpts = [hexpts; hx hy];        
end

%string of points from vertex to vertex
for h = 1 : 6
    cxy = hexpts(h,:);
    vec = hexpts(h+1,:) - hexpts(h,:);
    for i = 0 : 0.001 : 0.999
        xy = [xy; cxy + vec*i];
    end
end

