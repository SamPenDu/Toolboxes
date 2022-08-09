function img = BlackWhiteGratings(Stims, WinDim)
%img = BlackWhiteGratings(Stims, [WinDim])
% 
% Creates a black & white field of grating patches using the stimuli in Stims. 
%
% Parameters:
%   Stims :     Array of two stimulus structures (white & black)
%   WinDim :    Dimensions of image (optional, default = 400)
%
% Returns the final image.

if nargin < 2
    WinDim = 400;
end

% White stimulus
curW = GaborField(Stims(1), WinDim) - 0.5;
curW(find(curW < 0)) = 0;

% Black stimulus
curB = GaborField(Stims(2), WinDim) - 0.5;
curB(find(curB < 0)) = 0;

% Blank images for each colour channel
img = ones(size(curB,1), size(curW,2))/2;

% Update the image
img = img + curW - curB;

