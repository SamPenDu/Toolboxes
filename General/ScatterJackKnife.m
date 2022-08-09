function ScatterJackKnife(x,y,jk,col)
%
%ScatterJackKnife(x,y,jk,[col='k'])
%
% Shows scatter plot showing the results of the jack-knife procedure.
%

if nargin < 4
    col = [0 0 0];
end

scatter(x, y, 20, (col+[1 1 1])/2, '+'); 
hold on
set(gca, 'fontsize', 10);
scatter(x(jk), y(jk), 20, col, 'filled');
