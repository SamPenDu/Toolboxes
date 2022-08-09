function y = bse_binornd(x, n, j)
%
% y = bse_binornd(t, n, j)
%
% Randomly draws j probabilities (not 1s and 0s!) from a binomial distribution 
% with x successes out of n trials. This is used by bse_binom.
%

% Output vector
y = NaN(j,1); 

% Loop thru number of samples
for i = 1:j 
    % Is current sample done?
    r = false; 
    % While current sample isn't done
    while ~r 
        p = rand; % Pick random number between 0-1
        r = rand < binopdf(x,n,p); % Is random number within binomial probability?
    end
    % Add to output vector
    y(i) = p; 
end