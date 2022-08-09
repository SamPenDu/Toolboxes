function Stim = RandomField(N)
%Stim = RandomField(N)
%
% Generates a field with N randomly positioned elements.
%
% Parameters:
%   N :   Number of elements
%
% Returns new struct with field.
%

% Empty structure
Stim = struct;
Stim.N = 0;
Stim.X = [];
Stim.Y = [];
Stim.Theta = [];
Stim.Collinear = [];
Stim.IsContour = [];
Stim.Contrast = [];
Stim.Phase = [];
Stim.Sigma = 2;
Stim.Lambda = 8;

% Randomize elements
Stim.N = N;
Stim.X = rand(N,1) * 2 - 1;
Stim.Y = rand(N,1) * 2 - 1;
Stim.Theta = zeros(N,1);
Stim.Collinear = Stim.Theta;
Stim.IsContour = zeros(N,1);
Stim.Contrast = ones(N,1);
Stim.Phase = zeros(N,1);