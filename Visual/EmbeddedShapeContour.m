function Stim = EmbeddedShapeContour(Nelems, Params, Rotation)
%Stim = EmbeddedShapeContour(Nelems, Params, [Rotation])
%
% Generates a radial frequency shape contour embedded into relatively
% even background. The procedure generates the background by creating 
% many concentric shapes. However, only the shape with approximately 
% the defined radius is the collinear contour. Elements are created 
% outside of the square aperture of the display. Thus it is possible 
% to move the centre of the shape later.
%
% Parameters:
%   Nelems :    Number of elements in the contour
%   Params :    Vector with shape parameters:
%                   1) Radius of the base circle 
%                   2) Radial frequency of component sine wave
%                   3) Amplitude of first component  
%   Rotation :  Rotation of the shape in degrees (optional, default = 0)
%
% Returns the stimulus structure with the contour and background.
%

if nargin < 3
    Rotation = 0;
end

%the dummy contour to work out spacing
%calculate the desired contour
xy = RadFreqShape(Params(2), Rotation, [Params(1) Params(3) 0 0 0]);
%create a collinear contour out of the string
[dumcont spc] = CollinearContour(xy, Nelems);

%parameters of the shape 
rad = round(Params(1)/spc) * spc;
rfq = Params(2);
amp = Params(3) * spc;

%the real contour with adjusted spacing
%calculate the desired contour
xy = RadFreqShape(rfq, Rotation, [rad amp 0 0 0]);
%create a collinear contour out of the string
cont(1) = CollinearContour(xy, Nelems);

%create the concentric background shapes (beyond the edge of the display)
n = 1;  %counting the shapes
for rho = spc : spc : 2  
    %if not the shape, randomize orientations and unmark elements
    if rho ~= rad
        %generate the string of points
        xy = RadFreqShape(rfq, Rotation, [rho amp 0 0 0]);

        %current number of elements
        curel = ceil(rho / rad * Nelems);
        
        %create a collinear contour out of the string
        cont(n+1) = CollinearContour(xy, curel);

        cont(n+1).Theta = RandOri(cont(n+1).N,1);
        cont(n+1).Collinear = cont(n+1).Theta;
        cont(n+1).IsContour = zeros(cont(n+1).N,1);

        %next concentric contour
        n = n + 1;
    end
end

Stim = CombineStimuli(cont);

%elements inside the stimulus space
inels = find(abs(Stim.X) <= 1 & abs(Stim.Y) <= 1);
Stim.N = length(inels);
Stim.X = Stim.X(inels);
Stim.Y = Stim.Y(inels);
Stim.Theta = Stim.Theta(inels);
Stim.Collinear = Stim.Collinear(inels);
Stim.IsContour = Stim.IsContour(inels);
Stim.Contrast = Stim.Contrast(inels);
Stim.Phase = Stim.Phase(inels);
Stim.Sigma = Stim.Sigma(inels);
Stim.Lambda = Stim.Lambda(inels);
