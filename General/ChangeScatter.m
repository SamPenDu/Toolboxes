function ChangeScatter(xy1, xy2, vals, cmap)
%
% ChangeScatter(xy1, xy2, vals, [cmap])
%
% Creates a scatter plot showing how points in xy1 have shifted in xy2.
% These variables are both n x 2 matrices of two-dimensional observations.
% Each pair of points is connected by a line. The end point in xy2 is also
% indicated by a dot. The values in vals can be assigned as desired. They
% will be pseudocolour-coded using the colourmap in cmap, which defaults to
% a hot-cold map with green in the middle. If it is defined it should have
% 200 rows with 0 being the 101st.
%

if nargin < 4
    cmap = [winter(80); ... % Blue to blueish-green
            zeros(10,1), ones(10,1), linspace(0.5, 0, 10)'; ... % Blueish-green to green
            linspace(0,1,21)', linspace(1,0,21)', zeros(21,1); ... % Green to red
            ones(90,1), linspace(0,1,90)', zeros(90,1)]; % Red to yellow 
else
    cmap = eval([cmap '(201)']);
end

% Convert values into colour indeces
colx = round(vals / max(abs(vals)) * 100) + 101;

% Lines plot
hold on
for r = 1:size(xy1,1)
    line([xy1(r,1) xy2(r,1)], [xy1(r,2) xy2(r,2)], 'color', cmap(colx(r),:));
end

% Scatter plot
scatter(xy2(:,1), xy2(:,2), 20, cmap(colx,:), 'filled');
axis square

% Add color bar
colormap(cmap);
hb = colorbar;
set(hb, 'ytick', 0:.25:1, 'yticklabel', (-1:.5:1)*max(abs(vals)));
