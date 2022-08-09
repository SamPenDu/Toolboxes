function Xd = Rearr_rmaov2(X, nS)
%Xd = Rearr_rmaov2(X, nS)
%
% Rearranges data in matrix for 2-way repeated measures AnoVa.
% The order of factors is: Rows, Columns
%

nF1 = size(X,1) / nS;
nF2 = size(X,2);

Xd = [];
x = 1;

for f1 = 1 : nF1
    for f2 = 1 : nF2
        for sj = 1 : nS
            i = nS * (f1-1) + sj;
            Xd(x,:) = [X(i, f2), f1, f2, sj];
            x = x + 1;
        end
    end
end