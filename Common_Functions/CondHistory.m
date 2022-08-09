function [History Numbers] = CondHistory(Conditions)
% Returns a one-back history matrix for the numbered conditions.
%
% Counts the number of times that Row was preceded by Column.
% The first output History returns the probabilities.
% The second output Numbers returns the raw numbers.
% The input must include 0's for baseline conditions.
%

Cn = length(unique(Conditions));
Numbers = zeros(Cn,Cn);
for i=2:length(Conditions)
    Numbers(Conditions(i)+1, Conditions(i-1)+1) = Numbers(Conditions(i)+1, Conditions(i-1)+1) + 1; 
end
History = Numbers / (length(Conditions)-1);