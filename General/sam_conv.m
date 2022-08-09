function y = sam_conv(x,c,z)
% Convolution of x by c 
%  z is index of 0 in c (default = 0)

if nargin == 2
    z = 0;
end

nx = size(x,1);
nc = size(c,1);

y = zeros(z+nx+(nc-z),1); 
for i = z+1:nx 
    y(i-z:i-z+nc-1) = y(i-z:i-z+nc-1) + x(i)*c; 
end