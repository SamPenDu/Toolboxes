function d = Cohens_d(A,B)
%
% d = Cohens_d(A,B)
%
% Returns Cohen's d for a difference between samples A and B.
% If B is a scalar it instead calculates a one-sample t-test.
% For paired t-test first calculate differences in A and set B to 0.
%

% Sample sizes
na = length(A);
nb = length(B);

% One- or two-sample t-test?
if nb == 1
    %% One-sample t-test
    % Calculate differences in A to B
    A = A - B;
    
    % Standard deviation of differences
    s = std(A);
    
    % Mean of differences
    ma = mean(A);
    
    % Cohen's d
    d = ma ./ s;
else
    %% Two-sample t-test
    % Standard deviations
    sa = std(A);
    sb = std(B);

    % Sample means
    ma = mean(A);
    mb = mean(B);

    % Pooled standard deviation
    s = sqrt( ((na-1).*sa.^2 + (nb-1).*sb.^2) / (na+nb) );

    % Cohen's d
    d = (ma-mb) ./ s;
end
