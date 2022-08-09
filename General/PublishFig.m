function PublishFig(X, tlabs, accu)
% PublishFig(X, tlabs, accu)

% parameters
FontSize = 40;   % font size
LineWidth = 5;    % line width
% LineColor = [.4 .4 .4; .4 .4 .4; .6 .6 .6; .6 .6 .6; 0 0 0; 0 0 0];
% LineColor = [.5 .5 .5; .5 .5 .5; .5 .5 .5; 0 0 0; 0 0 0; 0 0 0];
LineColor = [0 0 0; 0 0 0; .246 .247 .247];
% LineStyle = {':' ':' '--' '--' '-' '-'};
FontName = 'Myriad Web Pro'; % type face
MarkerSize = 20;   % marker size
% MarkerType = 'ddooss';  % marker types
MarkerType = 'os^';
% MarkerColor = [1 1 1; .4 .4 .4; 1 1 1; .6 .6 .6; 1 1 1; 0 0 0];
% MarkerColor = [.5 .5 .5; .5 .5 .5; .5 .5 .5; 0 0 0; 0 0 0; 0 0 0];
MarkerColor = [1 1 1; 0 0 0; 1 1 1];

%set up general properties
figure; hold on;
set(gca, 'LineWidth', LineWidth, 'FontSize', FontSize);
set(gca, 'FontName', FontName);
lineobjs = findobj(gcf, 'Type', 'Line');
set(lineobjs, 'LineWidth', LineWidth);

% size of data array
[r c] = size(X);
% if even # cols = category plot, otherwise scatter plot
if mod(c,2)
    xvals = X(:,1);
    X = X(:,2:end);
    c = c-1;
    aoffs = 0.05;
else
    xvals = 1 : r;  % x values = number of rows
    aoffs = 0.1;
    set(gca, 'xtick', xvals);
    set(gca, 'xticklabel', tlabs);
end

% draw a line at chance
if accu == 1
    Chance = 50;
plot(min(xvals-0.1) : (max(xvals+0.9)-min(xvals-0.1))/50 : max(xvals+0.9), Chance, ...
     'Marker', 's', 'MarkerSize', 3, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);
end

% plot with errorbars
for i = 1 : c/2 
    errorbar(xvals, X(:,i), X(:,i+c/2), 'Color', LineColor(i,:), 'LineWidth', LineWidth, ... % 'LineStyle', LineStyle{i}, ... 
        'Marker', MarkerType(i), 'MarkerSize', MarkerSize, 'MarkerFaceColor', MarkerColor(i,:)); 
end
set(gca, 'TickLength', [0.02 0.02]);

% arrange axes
xrange = range(xvals);
if nargin > 2 & accu
    yrange = [35 100];
    set(gca, 'ytick', [40 : 10 : 100]);
else
    yrange = [-Inf Inf];
end
axis([min(xvals-xrange*aoffs) max(xvals+xrange*aoffs) yrange]);

maximize(gcf);
