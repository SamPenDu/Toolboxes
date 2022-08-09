function h = indobs(Y, x, col, siz)
%
%indobs(Y, x, [col=hsv(size(Y,2)), siz=1])
%
% See help for SaltAndPepper.m
%

% Number of variables
n = size(Y,2); 

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
h = SaltAndPepper(Y, x, col, siz);