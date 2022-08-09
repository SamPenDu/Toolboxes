function h = Spaghetti(Y, x, col, siz, ofs)
%
%Spaghetti(Y, x, [col=hawaii(size(Y,2)), siz=1, ofs=true])
%
% Plots means as well as individual paired observations in Y.
%   Essentially like SaltAndPepper except that individuals are connected by lines.
%   Y cannot be a cell array because sample sizes must be the same per condition.
%
%   The optional input ofs toggles whether there is a random x-offset for each individual line.
%   This is effectively the same as SaltAndPepper to allow you to better see individuals.  
%

% Number of variables
n = size(Y,1); 

if nargin < 2
    x = [];
    col = hawaii(n);
    siz = 1;
    ofs = true;
elseif nargin < 3
    col = hawaii(n);
    siz = 1;
    ofs = true;
elseif nargin < 4
    siz = 1;
    ofs = true;
elseif nargin < 5
    ofs = true;
end

% Standard x range?
if isempty(x)
    x = 1:size(Y,2);
end

% All same colour?
if size(col,1) == 1
    mcol = col;
    col = repmat(col, n, 1);
else
    mcol = [0 0 0];
end

% Plot data
hold on
for i = 1:size(Y,1)
    if ofs 
        ofsx = rand/10;
    else
        ofsx = 0;
    end
    plot(ofsx + x, Y(i,:), 'o-', 'linewidth', siz, 'color', (col(i,:)+[1 1 1])/2);
end
h = plot(x-(ofs*.1), nanmean(Y), 'd-', 'color', mcol, 'markeredgecolor', mcol, 'markerfacecolor', (mcol+[1 1 1])/2, 'markersize', 10*siz, 'linewidth', siz+1); 
hold off

set(gca, 'xtick', x(1):x(end));
xlim([0 x(end)+1]);
