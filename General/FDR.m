function corP = FDR(P, j)
%corP = FDR(P, j)
% Returns the False Discoverate Rate corrected p-value for significance P and number of contrasts j.
%

corP = (j+1) / (2*j) * P;