function ConOut = Vector2Connectogram(Vector, Connectogram)
%
% ConOut = Connectogram2Vector(Vector, Connectogram)
%
% Returns the data in the vector as a connectogram using the format defined
% by the input Connectogram (just uses the number of values per node).
%

ConOut = {};

% Loop thru nodes
x = 1;
for n = 1:length(Connectogram)
    ConOut{n,1} = [];
    for t = 1:length(Connectogram{n})
        ConOut{n} = [ConOut{n} Vector(x)]; % Add vector component to output
        x = x + 1; % Increase counter
    end
end
