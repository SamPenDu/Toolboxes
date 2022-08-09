function img = CheckerField(Stim, WinDim, Noise)%img = CheckerField(Stim, [WinDim, Noise])%% Draws a field of checker patches defined by the Stim. % The check size is defined by Stim.Lambda.% % Parameters:%   Stim :      Stimulus structure with parameters for each element%   WinDim :    Width of the image (optional)%   Noise :     Luminance noise from normal distribution (optional)%% The struct Stim contains the parameters:%   Stim.N =         Number of elements in display%   Stim.Sigma =     Standard deviation of the envelopes %   Stim.Lambda =    Size of the checks%% And per element parameters in row vectors:%   Stim.X =         X-coordinates%   Stim.Y =         Y-coordinates%% Returns the image with the checker board stimulus. %% ensure positioning is correctStim.Y = -Stim.Y;% find elements that are actually inside the stimulus spaceinels = find(abs(Stim.X) <= 1 & abs(Stim.Y) <= 1);% image dimensions in pixels if nargin < 2    WinDim = 400;    Noise = 0;elseif nargin < 3    Noise = 0;end% if size is the same in all elementsif length(Stim.Sigma) == 1    Stim.Sigma = ones(Stim.N,1) * Stim.Sigma;endif length(Stim.Lambda) == 1    Stim.Lambda = ones(Stim.N,1) * Stim.Lambda;end% size of actual image (depends on maximal Gabor size)winSize = WinDim + 4*max(Stim.Sigma) + 2;img = ones(winSize, winSize)/2 + randn(winSize, winSize)*Noise;% rendering the Gaborsfor i = inels'    % GaborElem(input image, sigma, theta, lambda, phase, xpos, ypos)    img = CheckerPatch(img, Stim.Sigma(i), Stim.Lambda(i)/2, ...  %Size of Gaussian and Checks        winSize/2 + round(Stim.X(i) * WinDim/2), ...  %X-coordinates        winSize/2 + round(Stim.Y(i) * WinDim/2), ...  %Y-coordinates        Stim.Contrast(i));    %contrast of element end% chop off the outer margin nowimg = img(2*max(Stim.Sigma)+2:winSize-(2*max(Stim.Sigma)+1), 2*max(Stim.Sigma)+2:winSize-(2*max(Stim.Sigma)+1));