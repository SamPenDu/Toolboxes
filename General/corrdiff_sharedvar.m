function [t2 p] = corrdiff_sharedvar(A, B, C, Spearman)
%
%[t2 p] = corrdiff_sharedvar(A, B, C, [Spearman=false])
%
% Williams/Steiger equation to test whether the correlation of A and B is different to that of A and C.
%   http://www.angelfire.com/wv/bwhomedir/notes/williams_steiger_test.pdf

if nargin < 4
    Spearman = false;
end    

N = size(A,1);

if Spearman
    r12 = corr(A,B,'type','spearman');
    r13 = corr(A,C,'type','spearman');
    r23 = corr(B,C,'type','spearman');
else
    r12 = corr(A,B);
    r13 = corr(A,C);
    r23 = corr(B,C);
end

R = (1-r12^2-r13^2-r23^2) + (2*r12*r13*r23);

t2 = (r13-r12) * sqrt( ((N-1)*(1+r23)) / (2*((N-1)/(N-3)) * R + ((r13+r12))^2/4 * (1-r23)^3) ); % Earlier version had 2 instead of 4

p = p_value(t2, N-3);

if nargout == 0
    new_line;
    disp(['t2(' n2s(N-3) ')=' n2s(t2) ', p=' n2s(p)]);
    new_line;
end