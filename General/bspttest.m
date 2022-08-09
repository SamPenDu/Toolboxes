function [h P Ci Stats] = bspttest(A, B, sims)

if nargin < 3
    sims = 1000;
end

% wb = waitbar(0, 'Simulations');

n = size(A,1);
Ts = []; 
for i=1:sims 
    sa = ceil(rand(n,1) * n);
    sb = ceil(rand(n,1) * n);
    As = A(sa);
    Bs = B(sb);
    [h p c s]=ttest(As,Bs); 
    Ts=[Ts; s.tstat]; 
%     waitbar(i/sims, wb); 
end
% close(wb);

% hist(Ts);
[ha pa ca sa] = ttest(A,B);
T = abs(sa.tstat);
P = mean(abs(Ts)>T);
h = P < 0.05;
Ci = prctile(Ts, [2.5 97.5]);
Stats = struct;
Stats.tstat = T;
Stats.df = size(A,1)-1;
Stats.Ts = Ts;
