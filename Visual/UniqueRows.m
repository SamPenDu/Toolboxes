function outmtr = UniqueRows(inmtr)
%outmtr = UniqueRows(inmtr)
%
% Removes redundant rows from a matrix.
% Returns cleaned matrix.
%

temp = inmtr(1,:);
outmtr = [];
outmtr = [outmtr; temp];

for i = 2 : size(inmtr,1)
    temp = inmtr(i,:);
    
    dupl = 0;
    for i = 1 : size(outmtr,1)
        if temp == outmtr(i,:)
            dupl = 1;
            break;
        end
    end

    if dupl == 0
        outmtr = [outmtr; temp];
    end
end

