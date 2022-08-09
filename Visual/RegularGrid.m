function Stim = RegularGrid(Cells)
%Stim = RegularGrid(Cells)
%
% Generates coordinates for a regular grid.
%
% Parameters:
%   Cells :   Width of grid cells (optional, default = 0.1)
%
% Returns new struct with grid.
%

if nargin == 0
    Cells = 0.1;
end

Stim = struct;
Stim.N = 0;
Stim.X = [];
Stim.Y = [];
Stim.Theta = [];
Stim.Collinear = [];
Stim.IsContour = [];
Stim.Contrast = [];
Stim.Phase = [];
Stim.Sigma = 10;
Stim.Lambda = 5;

%first create a background array
for y = -1+Cells/2 : Cells : 1
    x = [-1+Cells/2 : Cells : 1];
    %add element to stimulus 
    Stim.N = Stim.N + length(x);
    Stim.X(end+1:end+length(x)) = x;
    Stim.Y(end+1:end+length(x)) = y;
    Stim.Theta(end+1:end+length(x)) = 0;
    Stim.Collinear(end+1:end+length(x)) = 0;
    Stim.IsContour(end+1:end+length(x)) = 0;
    Stim.Contrast(end+1:end+length(x)) = 1;
    Stim.Phase(end+1:end+length(x)) = 0;
end

%transpose the vectors
Stim.X = Stim.X';
Stim.Y = Stim.Y';
Stim.Theta = Stim.Theta';
Stim.Collinear = Stim.Collinear';
Stim.IsContour = Stim.IsContour';
Stim.Contrast = Stim.Contrast';
Stim.Phase = Stim.Phase';
