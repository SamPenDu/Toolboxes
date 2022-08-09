function [pA, pB] = PermuteGroups(A, B)
% 
% Permutes the group assignment of subjects in groups A and B.
% These must be column vectors or matrices where each row is a subject.
% Use this to randomly permute the group assignment when analysing
% arbitrary group assignments as you have with twin pairs for example.
%

% Sample size
n = size(A,1);

% Random assignment (0=A, 1=B)
X = rand(n,1) > 0.5;

% Permuted groups
pA = [];
pB = [];
for i = 1:n
    if X(i)
        % Swap group
        pB = [pB; A(i,:)];
        pA = [pA; B(i,:)];
    else
        % Don't swap group
        pA = [pA; A(i,:)];
        pB = [pB; B(i,:)];
    end
end