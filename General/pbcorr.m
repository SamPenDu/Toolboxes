function [r p t] = pbcorr(x,y,beta)
%
%[r p t] = pbcorr(x, y, [beta=0.2])
%
% Calculates the percentage bend correlation 
%

if nargin < 3
    beta = 0.2;
end

temp = sort(abs(x-median(x)));
omhatx = temp(floor((1-beta)*length(x)));
temp = sort(abs(y-median(y)));
omhaty = temp(floor((1-beta)*length(y)));
a = (x-pbos(x,beta)) / omhatx;
b = (y-pbos(y,beta)) / omhaty;
a(a<=-1) = -1;
a(a>=1) = 1;
b(b<=-1) = -1;
b(b>=1) = 1;
r = sum(a.*b) / sqrt(sum(a.^2)*sum(b.^2));
t = r * sqrt((length(x)-2) / (1-r.^2));
p = 2 * (1-tcdf(abs(t),length(x)-2));

if nargout == 0
    r = ['R_pb=' n2s(r) ' ,p=' n2s(p) ', t=' n2s(t)];
end

function y = pbos(x, beta)
% 
% Compute the one-step percentage bend measure of location
%

temp = sort(abs(x-median(x)));
omhatx = temp(floor((1-beta)*length(x)));
psi = (x-median(x)) / omhatx;
i1 = length(psi(psi<-1));
i2 = length(psi(psi>1));
sx = x;
sx(psi<-1) = 0;
sx(psi>+1) = 0;
y = (sum(sx)+omhatx*(i2-i1)) / (length(x)-i1-i2);


