function OutStim = BackgroundPattern(InStim, Pattern, Param)
%OutStim = BackgroundPattern(InStim, Pattern, [Param])
%
% Organises the local orientations of the background elements.
%
% Parameters:
%   InStim :    Stimulus structure with contour and background
%   Pattern :   Character indicating the background pattern:
%                     '&'  Random noise
%                     '='  Parallel
%                     'o'  Concentric
%                     '*'  Radial
%                     'X'  Hyperbolic
%                     '@'  Anticlockwise spiral
%                     'G'  Clockwise spiral
%                     '~'  Sine waves
%                     '^'  Peaks (based on sine wave)
%     Param :     Parameter for pattern (optional, default = 45):
%                     Parallel = Orientation (in degrees)
%                     Spirals = Steepness (in degrees) 
%                     Sines = [Amplitude Frequency Phase]
%                     
% Returns the new stimulus struct.
%

OutStim = InStim;

if nargin < 3
    Param = 45;
end

%find the contour elements 
con = find(InStim.IsContour == 1);
%find the background elements
bgd = find(InStim.IsContour == 0);

if Pattern == '&'
    %randomly oriented
    for i = 1 : length(bgd)
        OutStim.Theta(bgd(i)) = RandOri;
    end
elseif Pattern == '='
    %parallel pattern
    for i = 1 : length(bgd)
        OutStim.Theta(bgd(i)) = Param;
    end
elseif Pattern == '~' || Pattern == '^'
    if Pattern == '^'
        peak = 90;
    else
        peak = 0;
    end
    %sine waves
    if length(Param) == 1
        Param = [Param 180 0];
    elseif length(Param) == 2
        Param = [Param 0];
    end
    amp = Param(1);
    frq = Param(2);
    pha = Param(3);
    for i = 1 : length(bgd)
        OutStim.Theta(bgd(i)) = sind(InStim.X(bgd(i))*frq + pha) * amp + peak; 
    end
else
    switch Pattern
        case 'o' %concentric
            hyperbola = 1;
            orioffset = 0;
        case 'X' %hyperbolic
            hyperbola = -1;
            orioffset = 90;
        case 'G' %clockwise spiral
            hyperbola = 1;
            orioffset = 90-Param;
        case '@' %anticlockwise spiral
            hyperbola = 1;
            orioffset = 90+Param;
        case '*' %radial
            hyperbola = 1;
            orioffset = 90;
        otherwise
            error('Invalid background arrangement!')
        end        
        for i = 1 : length(bgd)
            OutStim.Theta(bgd(i)) = atan2(InStim.X(bgd(i)), hyperbola * InStim.Y(bgd(i)))*180/pi + orioffset;
        end
    end
end
                    
