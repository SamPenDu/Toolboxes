function [buttons xy] = waitformouse(t)
%
%[buttons xy] = waitformouse(t)
%
% Uses Psychtoolbox functions to waits for a mouse click and returns the 
% pressed buttons. Also returns the coordinates at the click. 
%
% Parameters:
%   t :  Optional, defines the system time for which the program waits.
%

if nargin == 0
    t = Inf;
end
ts = GetSecs + t;

buttons = [0 0 0];
while ~any(buttons) && GetSecs < ts
    [x, y, buttons] = GetMouse;
end
xy = [x y];
