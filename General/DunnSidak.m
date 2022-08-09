function corP = DunnSidak(P, j)
%corP = DunnSidak(P, j)
% Returns the Dunn-Sidak corrected p-value for significance P and number of contrasts j.
%

corP = 1-(1-P)^j;