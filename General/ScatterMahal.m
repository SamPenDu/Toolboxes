function stats = ScatterMahal(a,b,cm,fc,wt)
%
% ScatterMahal(a, b, [cm='-hot', fc=true, wt=[]])
%
% Scatter plot on top of a smooth contour plot of the Mahalanobis distance.
%
% cm defines the colour map to be used. Default is '-hot'.
% If this begins with '-' the colour map is inverted (e.g. '-hot').
%
% fc toggles whether the contour plot is filled or not.
%
% wt contains weights for each data point in a and b.
%
% Requires the Statistics Toolbox.
%

% Default parameters
if nargin < 3
    cm = '-hot';    % Use colour map hot
    fc = true;      % Fill contours by default
    wt = [];        % No weights
elseif nargin < 4
    fc = true;      % Fill contours by default
    wt = [];        % No weights
elseif nargin < 5
    wt = [];        % No weights
end

if size(a,2) > 1
    A = a;
    B = b;
    a = a(:);
    b = b(:);
else
    A = a;
    B = b;
end

% Rescale weights 
if ~isempty(wt)
    wt = 1 ./ wt;
    wt = wt ./ max(wt(:));
end

% Determine axes dimensions
hold off
scatter(a,b);
ra = mean(a) + [-1 1] * 3*std(a);
rb = mean(b) + [-1 1] * 3*std(b);
% Calculate Pearson's correlation
stats = correl(a,b);
% Calculate Mahalanobis distance
[x y] = meshgrid(ra(1):range(ra)/100:ra(2),rb(1):range(rb)/100:rb(2));
gm = mahal([x(:) y(:)],[a b]);
gm = reshape(gm, size(x));
% Plot grid points as contours
if fc 
    contourf(x,y,gm,100,'linestyle','none');
else
    contour(x,y,gm,10,'linewidth',2);
end
% Colour map
if cm(1) == '-'
    % Invert if desired
    cm = flipud(colormap(cm(2:end)));
end
cm = colormap(cm);
% Determine scatter colour
if mean(cm(1:round(size(cm,1)/2),:),2) < 0.5
    scol = [1 1 1];
else
    scol = [0 0 0];
end
% Scatter plot
hold on
% Plot the actual data 
if exist('A', 'var')
    mrk = repmat('osdv^<>ph*', 1, ceil(size(A,1)/10));
    if size(A,1) > 10
        disp('Not enough markers for number of rows!');
    end
    for s = 1:size(A,1)
        if isempty(wt) || var(wt(:)) == 0
            scatter(A(s,:), B(s,:), 150, mrk(s), 'filled', 'markeredgecolor', scol, 'markerfacecolor', [1 1 1]/2, 'linewidth', 2);
        else
            scatter(A(s,:), B(s,:), 150, mrk(s), 'filled', 'markeredgecolor', repmat(wt(s,:)'-0.1,1,3), 'markerfacecolor', repmat(wt(s,:)',1,3), 'linewidth', 2);
        end
    end
else
    scatter(a,b,100,scol,'filled');
end
axis([ra rb]);
axis square
set(gca,'fontsize',15);