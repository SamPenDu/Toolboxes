function [x,Sim] = SimilarStrings(StrList, Str)
% 
% x = SimilarStrings(StrList, Str)
% 
% Returns the indices of strings in cell array StrList in the order of
% descending similarity to the comparison string Str. The second output Sim
% contains the actual similarity values.
%

Len = cellfun(@(s) length(s), StrList); % Length of strings
Sim = cellfun(@(s) wfEdits(s,Str), StrList); % Raw dissimilarity 
Sim = 1 - Sim / max(Len); % Similarity index
[Sim,x] = sort(Sim, 'descend'); % Sorted in order

end

% Wagner–Fischer algorithm to calculate the edit distance / Levenshtein distance.
function d = wfEdits(S1,S2)

N1 = 1+numel(S1);
N2 = 1+numel(S2);

D = zeros(N1,N2);
D(:,1) = 0:N1-1;
D(1,:) = 0:N2-1;

for r = 2:N1
    for c = 2:N2
        D(r,c) = min([D(r-1,c)+1, D(r,c-1)+1, D(r-1,c-1)+~strcmpi(S1(r-1),S2(c-1))]);
    end
end
d = D(end);

end
