function uw_theta = UnwrapDeg(theta)
% uw_theta = UnwrapDeg(theta)
%
% Returns the unwrapped angle utheta for any generic angle theta.
% This means the angle will be in the range -90 - +90 deg.

uw_theta = mod(theta,180);
uw_theta(uw_theta>90) = -(180-uw_theta(uw_theta>90)); 