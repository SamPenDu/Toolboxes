function CenterText(winPtr, text, size, color, font, bgd)
%CenterText(winPtr, text{, size, color, font, bgd})
% Draws text at the center of the screen. Can use line breaks (\n).
%
% Parameters:
%   winPtr :    Psychtoolbox winPtr pointer
%   text :      string that is to be drawn
%   size :      Optional, size of text as a factor (default is 1 = 40 pt)
%   color :     Optional, colour of text (default is black)
%   font :      Optional, font of text (default is 'Arial')
%   bgd :       Optional, background colour (default is grey)
%

if nargin < 3
    size = 1;
    color = [0 0 0];
    font = 'Garamond';
    bgd = [127 127 127];
elseif nargin < 4
    color = [0 0 0];
    font = 'Garamond';
    bgd = [127 127 127];
elseif nargin < 5
    font = 'Garamond';
    bgd = [127 127 127];
elseif nargin < 6
    bgd = [127 127 127];
end

% determine the length of the longest line
nl = strfind(text, '\n');
if ~isempty(nl) & nl(end) == length(text)-1
    % remove line break at the end
    nl = nl(1:end-1);
    text = text(1:end-2);
end
% indeces of the line beginnings (-1 to split the '\n' in half)
linidx = [1, nl-1, length(text)];
if length(linidx) == 2  
    % just one line 
    longtext = text;
else
    % fine longest the line
    linlens = diff(linidx);
    longest = max(linlens);
    longtext = text(linidx(find(linlens==longest(1))):linidx(find(linlens==longest(1))+1));
end

winRect = Screen('Rect', winPtr);
Screen('TextFont', winPtr, font);
Screen('TextSize', winPtr, round(size*40));
Screen('TextBackgroundColor', winPtr, bgd);
txtRect = Screen('TextBounds', winPtr, longtext); 
txtRect = CenterRect(txtRect, winRect);
DrawFormattedText(winPtr, text, txtRect(1), txtRect(2), color); 
