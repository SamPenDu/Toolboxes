function h = ContourPlot(X, Y, C);
% Like scatter but plots a smoothed contour plot of dots in X and Y with colours C.

T = delaunay(X, Y); % Triangulation
trisurf(T, X, Y, zeros(length(X),1), C, 'EdgeColor', 'none', 'FaceColor', 'interp'); % Smoothed contour plot
view(0, 90); % Bird's eye view