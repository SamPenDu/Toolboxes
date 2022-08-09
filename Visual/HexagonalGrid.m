function hexs = HexagonalGrid(Cells, Hexagons)
%hexs = HexagonalGrid(Cells, [Hexagons])
%
% Generates a hexagonal grid centred on the origin. 
%
% Parameters:
%   Cells :     Width of grid cells
%   Hexagons :  Number of hexagons (optional, by default fills the field)
%
% Returns stimulus structure.
%

if nargin < 2
    Hexagons = 2 / Cells;
    Rotation = 0;
elseif nargin < 3
    Rotation = 0;
end

Sigma = 10;
Lambda = 5;

hexs = [];
hexs.N = 1;
hexs.X = 0;
hexs.Y = 0;
hexs.Theta = 0;
hexs.Collinear = 0;
hexs.IsContour = 0;
hexs.Contrast = 1;
hexs.Phase = 0;
hexs.Sigma = 10;
hexs.Lambda = 5;

%create the hexagons 
for Rho = Cells : Cells : Cells*Hexagons  
    %number of current hexagon
    n = Rho/Cells;
    %current number of elements
    curel = 6 * n;
    
    %generate the string of points
    xy = Hexagon(Rho);

    %create a collinear contour out of the string
    cont = CollinearContour(xy, curel);
    cont.Theta = zeros(cont.N,1);
    cont.Collinear = cont.Theta;
    cont.IsContour = zeros(cont.N,1);
    cont.Contrast = ones(cont.N,1);
    cont.Phase = zeros(cont.N,1);
    cont.Sigma = Sigma;
    cont.Lambda = Lambda;
    
    cont = RotateStimulus(cont, Rotation);
    hexs = [hexs; cont];
end

hexs = CombineStimuli(hexs);

%elements inside the hexsulus space
inels = find(abs(hexs.X) <= 1 & abs(hexs.Y) <= 1);
hexs.N = length(inels);
hexs.X = hexs.X(inels);
hexs.Y = hexs.Y(inels);
hexs.Theta = hexs.Theta(inels);
hexs.Collinear = hexs.Collinear(inels);
hexs.IsContour = hexs.IsContour(inels);
hexs.Contrast = hexs.Contrast(inels);
hexs.Phase = hexs.Phase(inels);
hexs.Sigma = hexs.Sigma(inels);
hexs.Lambda = hexs.Lambda(inels);
