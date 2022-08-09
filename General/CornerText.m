function CornerText(str, pos, col, siz)
% CornerText(str, [pos='NW', col='k', siz=15])
%
% Puts some text in the corner of the current figure axes. 
%
%   str:    String to write
%   pos:    Corner to write in compass direction ('NW', 'SE', etc)
%           If this is prefixed with '-' it mirrors vertical offset (e.g. for images rather than plots) 
%   col:    Colour of text (default = 'k')
%   siz:    Font size (default = 15)

if nargin < 2
    pos = 'NW';
end
if nargin < 3
    col = 'k';
end
if nargin < 4
    siz = 15;
end

if pos(1) == '-'
    MirrorOffset = true;
    pos = pos(2:end);
else
    MirrorOffset = false;
end

ax = axis;
wx = (ax(2)-ax(1)) / 20; 
wy = (ax(4)-ax(3)) / 20;

switch upper(pos)
    case 'NE'
        x = ax(2) - wx;
        y = ax(4) - wy;
        ha = 'right';
        va = 'top';
    case 'NW'
        x = ax(1) + wx;
        y = ax(4) - wy;
        ha = 'left';
        va = 'top';
    case 'SW'
        x = ax(1) + wx;
        y = ax(1) + wy;
        ha = 'left';
        va = 'bottom';
    case 'SE'
        x = ax(2) - wx;
        y = ax(3) + wy;
        ha = 'right';
        va = 'bottom';
    otherwise
        error('Invalid location!');
end

if MirrorOffset
    if strcmpi(va, 'bottom')
        va = 'top';
    elseif strcmpi(va, 'top')
        va = 'bottom';
    end
end

text(x, y, str, 'HorizontalAlignment', ha, 'VerticalAlignment', va, 'Color', col, 'FontSize', siz);