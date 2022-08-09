function OutStim = JitterOris(InStim, Jitter, Unifrm)
%OutStim = JitterOris(InStim, Jitter, [Unifrm])
%
% Adds orientation jitter to the contour. 
% The base orientation is assumed to have been set.
% So if you want non-collinear alignments they have
% to already been made using LocalAlignment.
%
% Parameters:
%   InStim :    Stimulus struct with contour
%   Jitter :    Jitter level (if Inf = completely random) 
%   Unifrm :    Distribution to use (ignored for Jitter = Inf):
%                  1 = Uniform
%                  0 = Normal (default)
%
% Returns the transformed stimulus structure.
%

if nargin < 3
    Unifrm = 0;
end

OutStim = InStim;

%find the contour elements
con = find(InStim.IsContour == 1);
ncon = length(con);

if isinf(Jitter)
    %randomize the orientations
    OutStim.Theta(con) = RandOri(ncon,1);
else
    if Unifrm == 1
        Js = round(rand(ncon,1) * 2*Jitter) - Jitter;
    else
        Js = round(randn(ncon,1) * Jitter);
    end

    %save the original orientations
    OutStim.Theta(con) = InStim.Theta(con) + Js;
end

