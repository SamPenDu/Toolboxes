function h = SaltAndPepper(Y, x, col, siz)
%
%SaltAndPepper(Y, x, [col=hsv(size(Y,2)), siz=1])
%
% Plots means as well as individual observations in Y.
%  Each column of Y is a variable to plot. This can be a matrix or a 
%  cell array (in case you have different sample sizes).
%  The input x defines the x position of each distribution.
%   This can be left empty if you want to use 1:size(Y,2).
%  
%  The optional col defines the colour.
%  The optional wid defines the line width.
%

% Number of variables
n = size(Y,2); 

if nargin < 2
    x = [];
    col = hsv(n);
    siz = 1;
elseif nargin < 3
    col = hsv(n);
    siz = 1;
elseif nargin < 4
    siz = 1;
end

% Standard x range?
if isempty(x)
    x = 1:n;
end

% All same colour?
if size(col,1) == 1
    col = repmat(col, n, 1);
end

% Plot data
hold on
h = []; 
for i = 1:n
    if iscell(Y)
        % Cell array
        hs = scatter(randn(length(Y{i}),1)/10 + x(i), Y{i}, 50*siz, (col(i,:)+[1 1 1])/2, 'o', 'filled'); % Plot individual subjects
        if exist('OCTAVE_VERSION', 'builtin') == 0
          alpha(hs,.5);
        end
        h = [h; plot(x(i), nanmean(Y{i}), 'marker', 'd', 'markeredgecolor', 'k', 'markersize', 12*siz, 'color', col(i,:), 'markerfacecolor', col(i,:), 'linewidth', siz)]; % Plot mean +/- sem
    else
        % Matrix array
        hs = scatter(randn(size(Y,1),1)/10 + x(i), Y(:,i), 50*siz, (col(i,:)+[1 1 1])/2, 'o', 'filled'); % Plot individual subjects
        if exist('OCTAVE_VERSION', 'builtin') == 0
          alpha(hs,.5);
        end
        h = [h; plot(x(i), nanmean(Y(:,i)), 'marker', 'd', 'markeredgecolor', 'k', 'markersize', 12*siz, 'color', col(i,:), 'markerfacecolor', col(i,:), 'linewidth', siz)]; % Plot mean +/- sem
    end
end
hold off

set(gca, 'xtick', x(1):x(end));
xlim([0 x(end)+1]);
