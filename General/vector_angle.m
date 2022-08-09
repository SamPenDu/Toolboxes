function t = vector_angle(a,b)
% t = vector_angle(a,b)
%
% Calculates the angle between vectors a and b.

t = acos(dot(a,b)/(norm(a)*norm(b))) / pi*180;
