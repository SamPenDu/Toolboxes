function frames = GaborMovie(Stim, numFrames, velocity, foreground, background, imgdim, noncartesian)
%frames = GaborMovie(Stim, [numFrames, velocity, foreground, background, imgdim, noncartesian])
%
% Generates the frames of a dynamic Gabor field. Can create drifting,
% shimmering, or dimming Gabor movies.
% 
% Parameters :
%   Stim :          Stimulus array
%   numFrames :     Duration in number of frames (optional, default = 360)
%   velocity :      Velocity (optional, default = 30)
%                      For drifting and shimmering this is in degrees of phase
%                          (negative means its running backwards)
%                      For dimming this is in percent contrast
%                          (negative means its increasing the contrast)
%                      Alternatively, the velocity of each element can be
%                      defined individually in Stim.Velocity.
%   foreground :    Defines how the contour elements move (optional):
%                      'drift' =    drifts due to coherence phase change (default)
%                      'shimmer' =  shimmers due to scrambled phases
%                      'static' =   does not move at all
%                      'dim' =      contrast of element changes (can
%                                   also contain 'drift' or 'shimmer')
%   background :    Defines how the background elements move (optional)
%                      Options are the same as for foreground
%   imgdim :        Image dimensions (optional)
%   noncartesian :  Defines non-cartesian Gabors (optional)
%                       '*' radial, 'o' concentric
%
% Returns a Y x X x Z image matrix. The Z-dimension contains the frames. 

%default parameters
if nargin < 2
    numFrames = 64;
    velocity = 30;
    foreground = 'drift';
    background = 'drift';
    imgdim = 400;
elseif nargin < 3
    velocity = 30;
    foreground = 'drift';
    background = 'drift';
    imgdim = 400;
elseif nargin < 4
    foreground = 'drift';
    background = 'drift';    
    imgdim = 400;
elseif nargin < 5
    background = 'drift';
    imgdim = 400;
elseif nargin < 6
    imgdim = 400;
end

%ensure there are phase values
if ~isfield(Stim, 'Phase')
    Stim.Phase = zeros(Stim.N,1);
end

%ensure there are contrast values
if ~isfield(Stim, 'Contrast')
    Stim.Contrast = ones(Stim.N,1);
end

%ensure there are velocity values
if ~isfield(Stim, 'Velocity')
    Stim.Velocity = ones(Stim.N,1)*velocity;
end

%method strings are case insensitive
foreground = lower(foreground);
background = lower(background);

%contour and background elements
conel = find(Stim.IsContour == 1);
bgdel = find(Stim.IsContour == 0);

for fr = 1 : numFrames 
    %generate current frame
    if nargin < 7
        img = GaborField(Stim, imgdim);
    else
        img = NonCartesianField(Stim, noncartesian, imgdim);
    end

    %add image to frames
    frames(:,:,fr) = img;
    
    %contour elements in next frame
    if strfind(foreground, 'drift')
        Stim.Phase(conel) = Stim.Phase(conel) + Stim.Velocity(conel);
    elseif strfind(foreground, 'shimmer')
        Stim.Phase(conel) = Stim.Phase(conel) + RandSign(length(conel),1) .* Stim.Velocity(conel);  
    end
    if strfind(foreground, 'dim')
        Stim.Contrast(conel) = Stim.Contrast(conel) - Stim.Velocity(conel)/100;
    end

    %background elements in next frame
    if strfind(background, 'drift')
        Stim.Phase(bgdel) = Stim.Phase(bgdel) + Stim.Velocity(bgdel);
    elseif strfind(background, 'shimmer')
        Stim.Phase(bgdel) = Stim.Phase(bgdel) + RandSign(length(bgdel),1) .* Stim.Velocity(bgdel); 
    end
    if strfind(background, 'dim')
        Stim.Contrast(bgdel) = Stim.Contrast(bgdel) - Stim.Velocity(bgdel)/100;
    end

    %reverse dimming of max/min contrast elements 
    fadein = find(Stim.Contrast < 0);
    fadeout = find(Stim.Contrast > 1);
    Stim.Contrast(fadein) = 0;
    Stim.Contrast(fadeout) = 1;
    Stim.Velocity(fadein) = -Stim.Velocity(fadein);
    Stim.Velocity(fadeout) = -Stim.Velocity(fadeout);
end

