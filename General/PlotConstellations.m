function PlotConstellations(X, Y, Groups, Colour, Scale, LineStyle, Strengths)
%
% PlotConstellations(X, Y, Groups, Colour, Scale, LineStyle, Strengths)
%
% Plots the stats defined by X and Y coordinates as well as the connections
%  between them in the constellations defined by the cell array Groups. 
%
% Colour defines colour both the stars and links (default = 'k').
%  For plotting the intensity of links this should be a colour map.
%
% Scale defines the base width/size of links/dots (default = 1). 
%
% LineStyle defines the line style of the links (default = '-').
%
% Strengths is a cell array of the same size as Groups where each defines 
%  the intensity of each link within a range of 0-1 (default = {}). 
%  Requires that the input Colour is a colour map. 
%

if nargin < 4
    Colour = 'k';
    Scale = 1;
    LineStyle = '-';
    Strengths = {};
elseif nargin < 5
    Scale = 1;
    LineStyle = '-';
    Strengths = {};
elseif nargin < 6
    LineStyle = '-';
    Strengths = {};
elseif nargin < 7
    Strengths = {};
end

% Determine colours
if ischar(Colour) && length(Colour) > 1
    if Colour(1) == '-'
        Cmap = flipud(colormap([Colour(2:end) '(101)']));
        Colour = Cmap(end,:);
    else
        Cmap = colormap([Colour '(101)']);
        Colour = Cmap(1,:);
    end
end 

% Determine colour for intensities
if ~isempty(Strengths)
    ColourIndeces = {};
    for s = 1:length(Strengths)
        ColourIndeces{s} = floor(Strengths{s} * 100) + 1;
    end
end

% Plot connectogram
hold on
for s = 1:length(Groups)
    for c = 1:length(Groups{s})
        if isempty(Strengths)
            % No connection strengths defined
            line([X(s) X(Groups{s}(c))], [Y(s) Y(Groups{s}(c))], 'color', Colour, 'linewidth', Scale, 'linestyle', LineStyle);
        else        
            % Connection strengths defined
            if Strengths{s}(c) > 0
                line([X(s) X(Groups{s}(c))], [Y(s) Y(Groups{s}(c))], 'color', Cmap(ColourIndeces{s}(c),:), 'linewidth', Scale*Strengths{s}(c)+.001, 'linestyle', LineStyle);
            end
        end
    end
end
scatter(X, Y, 30*Scale, Colour, 'filled');
