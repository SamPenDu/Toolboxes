function tallerthanwide(h)

% Resize the window to be twice as wide as tall.
%
% widerthantall(h)

if nargin == 0
    h = gcf;
end

pos = get(h, 'Position');
set(h, 'Units', 'normalize', 'Position', [0 0 .5 1]);