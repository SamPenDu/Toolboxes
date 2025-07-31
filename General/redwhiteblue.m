function cmap = redwhiteblue(res)
%
% cmap = redwhiteblue([res=256])
%
% Returns a colour map going from red to white to blue. The input res defines 
% the number of steps, which must be a multiple of 2. By default res is 256. 
%
% 10/07/2022 - Written (DSS)
%

if nargin == 0
    res = 256;   
end
steps = res / 2; % Steps from one colour to the next

% Colour peaks
R = [1 0 0];
W = [1 1 1];
B = [0 0 1];

% Create the colour map
cmap = [];
cmap = [cmap; linspace(R(1), W(1), steps)', linspace(R(2), W(2), steps)', linspace(R(3), W(3), steps)'];
cmap = [cmap; linspace(W(1), B(1), steps)', linspace(W(2), B(2), steps)', linspace(W(3), B(3), steps)'];

% Upside down & too lazy to fix it
cmap = flipud(cmap); 