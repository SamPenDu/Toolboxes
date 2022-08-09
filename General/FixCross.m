function FixCross(window, colour)
%Puts a fixation cross in the centre of window.

if nargin < 2
    colour = [0 0 0];
end

winRect  = Screen('Rect', window);      %returns screen dimensions - should be [0 0 1280 1024] at BUIC
Screen('FillRect', window, colour, CenterRect([0 3 7 6], winRect));
Screen('FillRect', window, colour, CenterRect([3 0 6 7], winRect));
