function maximize(h)

% Maximize the size of a window to fill the entire screen.
%
% maximize(h)
%
% 05 Dec 2013 - now checks which monitor is left hand side (BdH)
% 19 Feb 2014 - changed how window is scaled (DSS)
% 24 Feb 2014 - more changes to make it work on multiple displays in testing room (DSS)

if nargin == 0
    h = gcf;
end
set(h, 'Units', 'Normalized');
set(h, 'Position', [0 0 1 1]);
