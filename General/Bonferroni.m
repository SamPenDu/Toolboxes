function corP = Bonferroni(P, j)
%corP = Bonferroni(P, j)
% Returns the Bonferroni corrected p-value for significance P and number of contrasts j.
%

corP = P/j;