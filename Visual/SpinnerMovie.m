function mov = SpinnerMovie(Grouping, Radius, Spoke, Speed, Width, Number)
%
% mov = SpinnerMovie(Grouping, Radius, Spoke, Speed, Width, [Number])
%
% Generates a movie with spinners.

if nargin < 6
    Number = 2;
end

f = 0;
for r = 0:Speed:360-Speed
    % Generate the spinners
    stim = CreateSpinner(r, Radius, Number);
    stim.Sigma = 10;
    stim.Lambda = 10; 
    switch upper(Grouping(1))
        case 'R'
            % Radial orientations
            Angles = [0 : 360/Number : 360-360/Number]';
            stim.Theta = -Angles-r;
        case 'T'
            % Tangential orientations
            Angles = [0 : 360/Number : 360-360/Number]';
            stim.Theta = -Angles-r-90;
        case 'D'
            % Different orientations
            Angles = [0 : 180/Number : 180-180/Number]';
            stim.Theta = -Angles-r;  
        case 'F'
            % Fixed different orientations
            Angles = [0 : 180/Number : 180-180/Number]';
            stim.Theta = -Angles;  
        case 'C'
            % Checkerboards
            Angles = [0 : 180/Number : 180-180/Number]';
            stim.Theta = -Angles;  
            stim2 = stim;
            stim2.Theta(:) = stim2.Theta + 90;
            stim = CombineStimuli([stim; stim2]);
        case {'M' 'G'}
            % Mexican hats / Gaussian dots
            stim.Lambda = stim.Sigma/2;
    end
    
    % Spinners for each quadrant
    allspinners = [];
    for t = 45:90:315
        [x y] = pol2cart(t/180*pi, Spoke);
        curr = stim;
        curr.X = curr.X + x;
        curr.Y = curr.Y + y;
        allspinners = [allspinners; curr];
    end
        
    % Combine all four spinners
    stim = CombineStimuli(allspinners);
    
    % Generate movie frames
    f = f + 1;
    if strcmpi(Grouping(1), 'M')
        mov(:,:,f) = MexicanField(stim, Width);
    elseif strcmpi(Grouping(1), 'G')
        mov(:,:,f) = DotField(stim, Width);
    else
        mov(:,:,f) = GaborField(stim, Width);
    end
end
