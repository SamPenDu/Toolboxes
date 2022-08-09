function n = DieRoll(nR, nS)
% n = DieRoll(nR, nS)
%
% Generate a list n of nR rolls of a die with nS sides.
%

% Generate die rolls
n = ceil(rand(nR,1) * nS);

