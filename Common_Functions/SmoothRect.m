function SmoothRect(WindowPtr, Color, Rect, Fringe)
%
% SmoothRect(WindowPtr, Color, Rect, Fringe)
%
% Draws a filled rect (using the PTB parameters) with a transparent fringe.
% If Fringe is negative, the rectangle is transparent & the edge becomes opaque.
%

% Fringe transparencies
Alphas = linspace(0, 255, abs(Fringe));

% Transparent shape?
if sign(Fringe) == -1
    Alphas = 255-Alphas; % Invert opaqueness
    Fringe = -Fringe; % Fringe must be positive now
end

% Loop thru fringe pixels
for f = 0:Fringe-1
    Screen('FillRect', WindowPtr, [Color Alphas(f+1)], [Rect(1)+f Rect(2)+f Rect(3)-f Rect(4)-f]);
end
