function Vector = Connectogram2Vector(Connectogram)
%
% Vector = Connectogram2Vector(Connectogram)
%
% Returns the data in the connectogram as a vector. Usually you would only
% do this if you first removed the redundant back-projections.
%

Vector = [];

% Loop thru nodes
for n = 1:length(Connectogram)
    Vector = [Vector; Connectogram{n}'];
end
