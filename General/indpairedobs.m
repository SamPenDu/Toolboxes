function h = indpairedobs(Y, x, col, siz)
%
%indpairedobs(Y, x, [col=hsv(size(Y,2)), siz=1])
%
% See help for Spaghetti.m
%

% Number of variables
n = size(Y,1); 

if nargin < 2
    x = [];
    col = hsv(n);
    siz = 1;
elseif nargin < 3
    col = hsv(n);
    siz = 1;
elseif nargin < 4
    siz = 1;
end

% Call actual function
h = Spaghetti(Y, x, col, siz);