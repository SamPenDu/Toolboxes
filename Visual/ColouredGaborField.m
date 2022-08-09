function img = ColouredGaborField(Stims, Cols, WinDim)
%img = ColouredGaborField(Stims, Cols, [WinDim])
% 
% Creates a coloured Gabor field of the stimuli in Stims. 
%
% Parameters:
%   Stims :     Array of one or many stimulus structures
%   Cols :      n x 3 matrix of the colours for each field
%                  (must have same number of rows as Stims)
%   WinDim :    Dimensions of image (optional, default = 400)
%
% Returns the final image.

if nargin < 3
    WinDim = 400;
end

OutStims = Stims;

% Blank images for each colour channel
img = GaborField(OutStims(1), WinDim) - 0.5;
dims = size(img);
imgR = ones(dims)/2;
imgG = ones(dims)/2;
imgB = ones(dims)/2;

% For every stimulus in structure array
for i = 1 : length(Stims)
    % Red
    OutStims(i).Contrast = Stims(i).Contrast * Cols(i,1);
    curR = GaborField(OutStims(i), WinDim) - 0.5;
    % Green
    OutStims(i).Contrast = Stims(i).Contrast * Cols(i,2);
    curG = GaborField(OutStims(i), WinDim) - 0.5;
    % Blue
    OutStims(i).Contrast = Stims(i).Contrast * Cols(i,3);
    curB = GaborField(OutStims(i), WinDim) - 0.5;
    
    % Update the images
    imgR = imgR + curR;
    imgG = imgG + curG;
    imgB = imgB + curB;
end

% Combine the colour channels
img = zeros(dims(1), dims(2), 3);
img(:,:,1) = imgR;
img(:,:,2) = imgG;
img(:,:,3) = imgB;
