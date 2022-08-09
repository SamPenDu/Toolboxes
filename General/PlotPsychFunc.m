function PlotPsychFunc(x,F,c,w)
%
% PlotPsychFunc(x,F,[c,w])
%
%   Plots a cumulative Gaussian psychometric function fitted with FitPsychFunc in F.
%       The optional c defines the colour as in the plot function.
%       The optional w defines the line width as a scalar.
%

if nargin < 3
    c = 'b';
    w = 1;
elseif nargin < 4
    w = 1;
end

s = range(x)/10000;
x = sort(x);
X = x(1) : s : x(end);

plot(X, F.function(X), 'color', c, 'linewidth', w);
