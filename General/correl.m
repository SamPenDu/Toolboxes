function [s jk ci] = correl(A, B, cortyp, bs)
%
%[s jk ci] = correl(A, B, [cortyp = 'p'], [bs = 0]])
%
% Returns a stats string for a correlation between A and B.
%
% The optional input cortyp defines the type of correlation:
%   'p' Pearson's r
%   's' Spearman's rho
%   'k' Kendall's tau
%   'w' Wilcox's percentage bend
%   '3' Shepherd's pi
%
% If bs > 0, confidence intervals are bootstrapped.
% If bs < 0, jack-knife correlation is calculated.
%
% If a jack-knife correlation is calculated, then jk contains the indeces
% of the data points at which the correlation is not significant.
%

%% Remove NaNs
X = rem_nan([A B]);
A = X(:,1); 
B = X(:,2);
n = size(X,1);

%% Default inputs
if nargin < 3
    cortyp = 'p';
    bs = 0;
elseif nargin < 4
    bs = 0;
end

%% Calculate correlation 
if lower(cortyp) == 'p'
    cortyp = 'pearson';
    corstr = 'r';
elseif lower(cortyp) == 's'
    cortyp = 'spearman';
    corstr = '\rho';
elseif lower(cortyp) == 'k'
    cortyp = 'kendall';
    corstr = '\tau';
end
if lower(cortyp) == 'w'
    [r p] = pbcorr(A,B);
    corstr = 'r';
elseif lower(cortyp) == '3'
    [r p] = Shepherd(A,B,10000);
    corstr = '\pi';
else
    [r p] = corr(A,B,'type',cortyp);
end

%% Bayes Factor
b = corrbf(r,n);

%% Nominal CI
nci = tanh(atanh(r) + norminv(0.025)/sqrt(n-3)*[1 -1]);
nci = round_decs(nci, 2);
if sign(nci(1)) == sign(nci(2))
    ncis = '*';
else
    ncis = '';
end
nci = [' [' n2s(nci(1)) ', ' n2s(nci(2)) '] ' ncis];

%% Bootstrapping or Jackknifing?
jk = [];
if bs > 0
    [br ci bp] = bscorr(A, B, bs, cortyp);
    ci = round_decs(ci, 2);
    jk = ci;
    if sign(ci(1)) == sign(ci(2))
        cis = '*';
    else
        cis = '';
    end
    ci = [' [' n2s(ci(1)) ', ' n2s(ci(2)) '] ' cis];
elseif bs < 0
    br = []; bp = []; 
    x = 1:length(A);
    for n = 1:length(A)
        Aj = A(x ~= n);
        Bj = B(x ~= n);
        if lower(cortyp) == 'w'
            [rj pj] = pbcorr(Aj, Bj);
        elseif cortyp(1) == '3'
            [rj pj] = Shepherd(Aj, Bj, 1000);
        else
            [rj pj] = corr(Aj, Bj, 'type', cortyp);
        end
        br = [br; rj];
        bp = [bp; pj];
        jk = [jk; pj>0.05];
    end
    jk = find(jk);
    ci = [min(br) max(br)];
    ci = round_decs(ci, 2);
    ci = [' [' n2s(ci(1)) ', ' n2s(ci(2)) ']; ' n2s(mean(bp<0.05)*100) '% significant'];
else
    ci = 'n/a';
end

%% Output string
if round_decs(p,4) < 0.0001
    s = [corstr ' = ' n2s(round_decs(r,2)) ', p < 0.0001'];
else 
    s = [corstr ' = ' n2s(round_decs(r,2)) ', p = ' n2s(round_decs(p,4))];
end
new_line;
disp(s);
disp(['Bootstrapped CI: ' ci]);
disp(['Parametric CI:   ' nci]);
disp(evidence(b));
new_line;