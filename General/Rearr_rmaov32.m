function Xd = Rearr_rmaov32(X, nS)
%Xd = Rearr_rmaov32(X, nS)
%
% Rearranges data in matrix for 3-way repeated measures AnoVa.
% The order of factors is: Rows, Columns, Levels
%

nF1 = size(X,3);
nF2 = size(X,1) / nS;
nF3 = size(X,2);

Xd = [];
x = 1;

for f1 = 1 : nF1
    for f2 = 1 : nF2
        for f3 = 1 : nF3
            for sj = 1 : nS
                i = nS * (f2-1) + sj;
                Xd(x,:) = [X(i, f3, f1), f1, f2, f3, sj];
                x = x + 1;
            end
        end
    end
end