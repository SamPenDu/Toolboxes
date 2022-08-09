function OutStim = EmptyField
%OutStim = EmptyField
% Creates the structure for an empty Gabor field stimulus.
%

OutStim = struct;    
OutStim.N = 0;
OutStim.X = [];
OutStim.Y = [];
OutStim.Theta = [];
OutStim.Collinear = [];
OutStim.IsContour = [];
OutStim.Contrast = [];
OutStim.Phase = [];
OutStim.Sigma = [];
OutStim.Lambda = [];

