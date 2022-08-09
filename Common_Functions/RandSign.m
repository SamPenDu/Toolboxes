function sgn = RandSign(m,n)
%Randomly generates either 1 or -1. Returns m x n matrix 
% (both are optional and 1 by default).
%

if nargin == 0
    m = 1;
    n = 1;
elseif nargin == 1
    n = 1;
end

sgn = round(rand(m,n))*2-1;