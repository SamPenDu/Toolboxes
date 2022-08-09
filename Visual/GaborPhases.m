function OutStim = GaborPhases(InStim, Pha)
%OutStim = GaborPhases(InStim, Pha)
%
% Determines the phase of the Gabors in the stimulus.
% Can also randomize 0-315 deg in 45 deg increments.
%
% Parameters:
%   InStim :    Input stimulus structure
%   Pha :       Phase of the Gabors (Inf for random)
%
% Returns the transformed stimulus.
%

OutStim = InStim;

if isinf(Pha)
    phases = floor(rand(InStim.N,1)*8) * 45;
else
    phases = ones(InStim.N,1) * Pha;
end

OutStim.Phase = phases;