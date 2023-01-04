function h = cateye(Y, x, col, wid, rawhist)
%
%cateye(Y, x, [col=hsv(size(Y,2)), wid=2, rawhist])
%
% Plots cat eye (violin) graph showing how data Y are distributed (using kernel density function).
%  Each column of Y is a variable to plot a cat eye for. Y can be either a matrix or cell array. 
%  The input x defines the x position of each cat eye.
%   This can be left empty if you want to use 1:size(Y,2).
%  
%  The optional col defines the colour.
%  The optional wid defines the line width.
%  If the optional rawhist is true, the raw histogram is plotted.
%

% Number of variables
n = size(Y,2); 

if nargin < 2
    x = [];
    col = hsv(n);
    wid = 2;
    rawhist = false;
elseif nargin < 3
    col = hsv(n);
    wid = 2;
    rawhist = false;
elseif nargin < 4
    wid = 2;
    rawhist = false;
elseif nargin < 5
    rawhist = false;
end

% Standard x range?
if isempty(x)
    x = 1:n;
end

% All same colour?
if size(col,1) == 1
    col = repmat(col, n, 1);
end

% Plot cat eyes
hold on
h = []; 
for i = 1:n
    if iscell(Y)
        cY = Y{i};
    else
        cY = Y(:,i);
    end   
    qs = prctile(cY, [25 75]); % Quartiles
    if rawhist
        [dn, dx] = hist(cY); % Raw histogram
    else
        [dn, dx] = ksdensity(cY, min(cY):range(cY)/100:max(cY)); % Smooth distribution
    end
    dn = dn / max(dn) * 0.2; % Normalise density
    h = [h; fill([dn -fliplr(dn)]+x(i), [dx fliplr(dx)], (col(i,:)+[2 2 2])/3, 'edgecolor', col(i,:), 'linewidth', wid)]; % Plot cat eye
    line([1 1] * x(i), qs, 'color', (col(i,:)+[0 0 0])/2, 'linewidth', wid); % Plot inter-quartile range
    scatter(x(i), median(cY), 80, 'o', 'markeredgecolor', (col(i,:)+[0 0 0])/2, 'markerfacecolor', (col(i,:)+[0 0 0])/2, 'linewidth', wid); % Plot median
    scatter(x(i), mean(cY), 120, '*', 'markeredgecolor', (col(i,:)+[0 0 0])/2, 'linewidth', wid); % Plot mean
end
hold off

set(gca, 'xtick', x(1):x(end));
xlim([0 x(end)+1]);
