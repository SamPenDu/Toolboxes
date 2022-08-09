function arc = VisArc(W, D)
%arc = VisArc(W, D)
% Returns the visual angle in degrees of stimulus 
% with width W and viewing distance D.

arc = 2 * atan2(W/2, D) * 180/pi;