function ss = tteststr(p, t, df, k)
%
% Returns a textual output of a t-test with p, t, and df.
% If the optional k is defined this determines the number of comparisons in Bonferroni correction.
%

if nargin < 4
    k = 1;
end
if k > 1
    sg = '(corr.) ';
else
    sg = [];
end

if p < 0.001
    sg = [sg '***'];
    ss = ['t(' num2str(df) ')=' num2str(round(t,2)) ', p=' num2str(round(p,5)) ' ' sg];
elseif p < 0.01
    sg = [sg '**'];
    ss = ['t(' num2str(df) ')=' num2str(round(t,2)) ', p=' num2str(round(p,5)) ' ' sg];
elseif p < 0.05
    sg = [sg ' *'];
    ss = ['t(' num2str(df) ')=' num2str(round(t,2)) ', p=' num2str(round(p,5)) ' ' sg];
else
    sg = [sg ' n.s.'];
    ss = ['t(' num2str(df) ')=' num2str(round(t,2)) ', p=' num2str(round(p,5)) ' ' sg];
end

