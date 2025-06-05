function [buttons, xy] = waitformouse(t, esc)
%
%[buttons, xy] = waitformouse(t, esc)
%
% Uses Psychtoolbox functions to waits for a mouse click and returns the 
% pressed buttons. Also returns the coordinates at the click. 
%
% Parameters:
%   t :     Optional, defines the system time for which the program waits.
%   esc :   Optional, if true also waits for keyboard ESC
%           This returns all three buttons as true!
%

if nargin == 0
    t = Inf;
end
if nargin < 2
    esc = false;
end

ts = GetSecs + t;
buttons = [0 0 0];
while ~any(buttons) && GetSecs < ts
    [x, y, buttons] = GetMouse;
    if esc
        [~,~,k] = KbCheck;
        if ismember(find(k,1), KbName('Escape'))
            buttons(:) = 1;
        end
    end
end
xy = [x y];
