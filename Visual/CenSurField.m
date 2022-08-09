function img = CenSurField(Stim, WinDim, Noise)%img = CenSurField(Stim, [WinDim, Noise])%% Draws a field of centre-surround Gabor elements defined by the Stim. % % Parameters:%   Stim :      Stimulus structure with parameters for each element%   WinDim :    Width of the image (optional)%   Noise :     Luminance noise from normal distribution (optional)%% The struct Stim contains the parameters:%   Stim.N =         Number of elements in display%   Stim.Sigma =     Standard deviation of the envelopes (optional)%   Stim.Lambda =    Wavelength of the carrier waves (optional)%% And per element parameters in row vectors:%   Stim.X =         X-coordinates%   Stim.Y =         Y-coordinates%   Stim.Theta =     Orientation of central carrier wave %   Stim.Surround =  Orientation of surround carrier wave%   Stim.Phase =     Phase of carrier waves (optional, default = 0)%   Stim.Contrast =  Contrast of elements (optional, default = 1)%   Stim.IsContour = Marker for contour elements (optional, by default all are marked)%   Stim.Collinear = Orientation of carrier waves if contour is collinear%% Returns an image which can be displayed or saved to disk. %% ensure positioning is correctStim.Y = -Stim.Y;% find elements that are actually inside the stimulus spaceinels = find(abs(Stim.X) <= 1 & abs(Stim.Y) <= 1);% image dimensions in pixels if nargin < 2    WinDim = 400;    Noise = 0;elseif nargin < 3    Noise = 0;end% if size & wavelength are the same in all elementsif length(Stim.Sigma) == 1    Stim.Sigma = ones(Stim.N,1) * Stim.Sigma;endif length(Stim.Lambda) == 1    Stim.Lambda = ones(Stim.N,1) * Stim.Lambda;end% size of actual image (depends on maximal Gabor size)winSize = WinDim + 4*max(Stim.Sigma) + 2;img = ones(winSize, winSize)/2 + randn(winSize, winSize)*Noise;% rendering the Gaborsfor i = inels'    % GaborElem(input image, sigma, theta, lambda, phase, xpos, ypos)    img = CenSurGabor(img, Stim.Sigma(i), [Stim.Theta(i) Stim.Surround(i)], Stim.Lambda(i), Stim.Phase(i), ...   %Gabor characteristics         winSize/2 + round(Stim.X(i) * WinDim/2), ...  %X-coordinates        winSize/2 + round(Stim.Y(i) * WinDim/2), ...  %Y-coordinates        Stim.Contrast(i));    %contrast of element end% chop off the outer margin nowimg = img(2*max(Stim.Sigma)+2:winSize-(2*max(Stim.Sigma)+1), 2*max(Stim.Sigma)+2:winSize-(2*max(Stim.Sigma)+1));