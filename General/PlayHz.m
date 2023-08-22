function PlayHz(Hz, Sec)
%
% PlayHz(Hz, [Sec=0.5])
%
% Uses in-built Matlab function to play a pure tone at frequency Hz for Sec seconds
% at the standard sampling frequency of 8192 Hz. If undefined, Sec is 0.5 s.
%

% Default duration?
if nargin < 2
    Sec = 0.5;
end
% Degrees per sample
d = 360/8192; 
% Play sound
sound(sind((0:d:360*Sec-d)*Hz));
