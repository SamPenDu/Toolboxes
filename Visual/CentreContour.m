function OutStim = CentreContour(InStim)
%OutStim = CentreContour(InStim)
%
% Centres the position of the contour in InStim within the display.
%

minX = min(InStim.X);
maxX = max(InStim.X);

minY = min(InStim.Y);
maxY = max(InStim.Y);

cenX = (maxX + minX) / 2;
cenY = (maxY + minY) / 2;

OutStim = InStim;

OutStim.X = OutStim.X - cenX;
OutStim.Y = OutStim.Y - cenY;
