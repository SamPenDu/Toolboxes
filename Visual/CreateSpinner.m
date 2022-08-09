function stim = CreateSpinner(Rotation, Radius, Number)
%
% stim = CreateSpinner(Rotation, Radius, [Number = 2])
%
% Generates a spinner at the defined orientation and radius.
% If number is defined this defines the number of elements (default = 2).

if nargin < 3
    Number = 2;
end

Angles = [0 : 360/Number : 360-360/Number]';

% Generate spinner
stim = EmptyField;
[x y] = pol2cart((Rotation+Angles)/180*pi, Radius);
for i = 1:length(Angles)
    stim = AddElement(stim, [x(i) y(i)], 0, 1, .5, 0, 10, 10);
    stim = AddElement(stim, [x(i) y(i)], 90, 1, .5, 0, 10, 10);
end
