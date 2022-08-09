function Stim = GridBackground(Cont, Dfgd, MinDist)
%Stim = GridBackground(Cont, Dfgd, [MinDist])
%
% Embeds the contour in Cont into a jittered grid background.
% First one jitter element is added per cell (unless it's too close).
% Then the empty spots are filled in using a finer unjittered grid.
%
% Parameters:
%   Cont :      Struct with contour elements (can be empty)
%   Dfgd :      Spacing of the contour elements
%   MinDist :   Minimum distance relative to cell width = Dfgc * 0.625
%                  (optional, default = 0.75)
%
% Returns new struct with background.
%

%if empty, add dummy elements
if isempty(Cont)
    removels = 1;
    Cont = struct;
    Cont.N = 10;
    Cont.X = repmat(10,10,1);
    Cont.Y = repmat(10,10,1);
    Cont.Theta = repmat(10,10,1);
    Cont.Collinear = repmat(10,10,1);
    Cont.IsContour = ones(10,1);
    Cont.Contrast = ones(10,1);
    Cont.Phase = zeros(10,1);
    Cont.Sigma = 10;
    Cont.Lambda = 5;
else
    removels = 0;
end

%calculate appropriate cell size
Cells = Dfgd * 0.625; % = 1/1.6 (cf. Braun 1999)  

if nargin < 3
    MinDist = 0.75;
end

Stim = Cont;
Sigma = Cont.Sigma(1);
Lambda = Cont.Lambda(1);

if length(Stim.Sigma) == 1
    Stim.Sigma = ones(Stim.N,1) * Sigma;
end
if length(Stim.Lambda) == 1
    Stim.Lambda = ones(Stim.N,1) * Lambda;
end

%first create a background array
for gx = -1+Cells/2 : Cells : 1
    for gy = -1+Cells/2 : Cells : 1
        %jittered positions within each cell
        x = gx + rand*Cells - Cells/2;
        y = gy + rand*Cells - Cells/2;
        
        %work out immediate neighbourhood
        n = Neighbourhood([x y], [Stim.X Stim.Y]);
        
        %if not too close to any element
        if norm(n(1,:) - [x y]) >= Cells * MinDist
            %add element to stimulus 
            Stim.N = Stim.N + 1;
            Stim.X(end+1) = x;
            Stim.Y(end+1) = y;
            Stim.Theta(end+1) = 0;
            Stim.Collinear(end+1) = 0;
            Stim.IsContour(end+1) = 0;
            Stim.Contrast(end+1) = 1;
            Stim.Phase(end+1) = 0;
            Stim.Sigma(end+1) = Sigma;
            Stim.Lambda(end+1) = Lambda;
        end
    end
end

%now fill up the empty spaces
for gx = -1+Cells/4 : Cells/2 : 1
    for gy = -1+Cells/4 : Cells/2 : 1
        %work out immediate neighbourhood
        n = Neighbourhood([x y], [Stim.X Stim.Y]);
        
        %if not too close to any element
        if norm(n(1,:) - [x y]) >= Cells * MinDist
            %add element to stimulus
            Stim.N = Stim.N + 1;
            Stim.X(end+1) = x;
            Stim.Y(end+1) = y;
            Stim.Theta(end+1) = 0;
            Stim.Collinear(end+1) = 0;
            Stim.IsContour(end+1) = 0;
            Stim.Contrast(end+1) = 1;
            Stim.Phase(end+1) = 0;
            Stim.Sigma(end+1) = Sigma;
            Stim.Lambda(end+1) = Lambda;
        end
    end
end

%if no contour, remove dummy elements
if removels == 1
    Stim.N = Stim.N - 10;
    Stim.X = Stim.X(11:end);
    Stim.Y = Stim.Y(11:end);
    Stim.Theta = Stim.Theta(11:end);
    Stim.Collinear = Stim.Collinear(11:end);
    Stim.IsContour = Stim.IsContour(11:end);
    Stim.Contrast = Stim.Contrast(11:end);
    Stim.Phase = Stim.Phase(11:end);
    Stim.Sigma = Stim.Sigma(11:end);
    Stim.Lambda = Stim.Lambda(11:end);
end
