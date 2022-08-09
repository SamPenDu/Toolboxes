function OutStim = RemoveEccentric(InStim,Num)
%OutStim = RemoveEccentric(InStim,Num)
%
% Picks elements in order of descending eccentricity.
%
% Parameters:
%   InStim :   Input stimulus struct
%   Num :      Remaining number of elements
%
% Returns the transformed stimulus.
%

OutStim = InStim;
OutStim.N = Num;

%eccentricities of elements
eccs = [];
for i = 1 : InStim.N
    eccs = [eccs; norm([InStim.X(i) InStim.Y(i)])];
end

%sort by eccentricity
[eccs ix] = sort(eccs);

%select the desired number
OutStim.X = InStim.X(ix(1:Num));
OutStim.Y = InStim.Y(ix(1:Num));
OutStim.Theta = InStim.Theta(ix(1:Num));
OutStim.Phase = InStim.Phase(ix(1:Num));
OutStim.Contrast = InStim.Contrast(ix(1:Num));
OutStim.IsContour = InStim.IsContour(ix(1:Num));
OutStim.Collinear = InStim.Theta(ix(1:Num));
if length(InStim.Sigma) > 1
    OutStim.Sigma = InStim.Sigma(ix(1:Num));
end
if length(InStim.Lambda) > 1
    OutStim.Lambda = InStim.Lambda(ix(1:Num));
end

