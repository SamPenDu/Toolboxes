function X = Semi_Random_Order(V,R)
%X = Semi_Random_Order(V,R)
%
% Generates a vector comprising R repeats of V, with the constraint that no
% number may appear twice in a row.
%

X = [];

X = Shuffle(V);
for i = 1 : R-1
    C = Shuffle(V);
    while C(1) == X(end)
        C = Shuffle(V);
    end
    X(end+1:end+length(C)) = C;
end


