function img = PhaseShiftIllusion(shift, theta)
%img = PhaseShiftIllusion(shift, theta)
%
% Generates a phase shift illusion grating.
%   shift = positive (+1), negative (-1) or no phase shift (0)
%   theta = degree of orientation tilt in opposite direction
%

%% Parameters
elemdist = 0.2;
horshift = 0.5;
sigma = 10;
lambda = 20;
phaseshift = 45;

stim = EmptyField;
ncont = 0;

for ypos = -1+horshift/2 : horshift : 1-horshift/2
    cont = EmptyField;
    ncont = ncont + 1;
    cont.X = cosd(theta)*(-.8:elemdist:.8)';
    cont.N = length(cont.X);
    cont.Y = sind(theta)*(-.8:elemdist:.8)' + ypos*ones(cont.N,1);
    cont.Theta = zeros(cont.N,1);
    cont.Collinear = cont.Theta;
    cont.IsContour = zeros(cont.N,1);
    cont.Contrast = ones(cont.N,1);
    cont.Phase = (0:phaseshift:phaseshift*cont.N-1)' * sign(isodd(ncont)-.5); 
    cont.Sigma = sigma;
    cont.Lambda = lambda;
    cont.IsContour(cont.X==0) = 1;
    stim = CombineStimuli([stim; cont]);
end

stim = RotateStimulus(stim, 90);
img = GaborField(stim, 400);
