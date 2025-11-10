function rX = RandSelUnequalProb(X, P, n)
% rX = RandSelUnequalProb(X, P, [n=1])
%
% Selects n random elements from matrix X using the 
% probability matrix P that any given element is picked. 
%
% Important: P and X must have the same dimensions!
%
% First it runs a uniform randomiser on all elements of X. 
% Any that pass the threshold defined in P pass triage.
% Out of these candidates, n are the chosen at random. 
% If fewer than n pass triage, some triaged ones are added.
%
% Returns a column vector of the chosen elements
%
% 31/07/2025 - Written (DSS)
% 04/11/2025 - Default n is now 1 (DSS)

if nargin < 3
    n = 1;
end

if mean(size(X) == size(P)) ~= 1
    error('Dimensions of X and P must be identical!');
end
if n > numel(X)
    error('n must be equal or less than the size of X!');
end

C = rand(size(X)) < P; % Random candidates that have been chosen
nc = sum(C(:)); % Number of candidates that passed triage

% If too few candidates passed triage
if nc < n
    tx = find(~C); % Indeces of triaged candidates 
    tx = tx(randperm(length(tx))); % Shuffle order
    tx = tx(1:n-nc); % Random 1-n triaged candidates
    C(tx) = 1; % Add these to candidates
end

% Select n candidates
rX = X(C); % Candidate elements
rX = rX(randperm(length(rX))); % Shuffle order
rX = rX(1:n); % First n candidates

% Ensure column vector
if size(rX,1) == 1
    rX = rX';
end

