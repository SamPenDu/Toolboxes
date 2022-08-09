function CategFig(X, tlabs, accu)
% CategFig(X, tlabs, accu)

% parameters
FontSize = 40;   % font size
LineWidth = 5;    % line width
% LineColor = [.6 .6 .6; 0 0 0; .4 .4 .4]; 
LineColor = [0 0 0; 0 0 0; .5 .5 .5; .5 .5 .5]; 
FontName = 'Myriad Web Pro'; % type face
MarkerSize = 20;   % marker size
% MarkerColor = [.6 .6 .6; 0 0 0; .4 .4 .4]; 
MarkerColor = [1 1 1; 0 0 0; 1 1 1; .5 .5 .5]; 
% MarkerType = 'osd';  % marker types
MarkerType = 'oooo';  % marker types

for j = 1 : length(tlabs)
    tlabs{j} = ['                   ' tlabs{j}];
%     tlabs{j} = ['         ' tlabs{j}];
end

%set up general properties
figure; 
hold on;
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
else
    Chance = 0;
end
plot(min(xvals-0.1) : (max(xvals+0.9)-min(xvals-0.1))/50 : max(xvals+0.9), Chance, ...
     'Marker', 's', 'MarkerSize', 3, 'MarkerEdgeColor', [.5 .5 .5], 'MarkerFaceColor', [.5 .5 .5]);

m = 0;
ms = [0 1 0 1];
% plot with errorbars
for i = 1 : c/2 
    m = ms(i)*0.33 + 0.33;
%     m = (i-1)*(1/(c/2)) + 0.05;
    errorbar(xvals+m, X(:,i), X(:,i+c/2), 'Color', LineColor(i,:), 'LineWidth', LineWidth, 'LineStyle', 'none', ... 
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
axis([min(xvals-0.25) max(xvals+1) yrange]);

maximize(gcf);


