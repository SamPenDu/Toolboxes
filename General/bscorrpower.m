function [pS pR pW] = bscorrpower(e,n)
% Simulates the power to detect correlation with an error magnitude e with sample size n.
% You can use correrr to find the relevant error magnitude for a particular correlation coefficient r.
% Returns power for Spearman's rho (pS), Pearson's r (pR) and Wilcox's percentage bend (pW).
%

Pp=[]; Ps=[]; Pw=[]; 

for i = 1:1000 
    a = randn(n,1); 
    b = a + e*randn(n,1); 
    [rp pp]=corr(a,b); 
    [rs ps]=corr(a,b,'type','spearman');
    [rw pw]=pbcorr(a,b);
    Pp = [Pp; pp]; 
    Ps = [Ps; ps]; 
    Pw = [Pw; pw]; 
end

pR = mean(Pp <= .05);
pS = mean(Ps <= .05);
pW = mean(Pw <= .05);
