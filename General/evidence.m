function se = evidence(bf10)
%
% se = evidence(bf10)
%
% Returns a nice little string giving an interpretation of a Bayes factor.
% Use in combination with corrbf.m and similar functions.
%

% Log evidence
le = log(bf10); 

% Which hypothesis is supported?
if le < 0
    h = 'H0';
else
    h = 'H1';
end

% How strong is the evidence?
e = exp(abs(le));
if e > 1 && e <= 3
    s = 'Anecdotal';
elseif e > 3 && e <= 10
    s = 'Substantial';
elseif e > 10 && e <= 30
    s = 'Strong';
elseif e > 30 && e <= 100
    s = 'Very strong';
elseif e > 100 
    s = 'Decisive';
else
    s = NaN;
end

% Output string
se = [s ' evidence for ' h ' (' sprintf('%1.3f', bf10) ')'];
