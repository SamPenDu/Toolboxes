function err = sem_within_subj(X)
% err = sem_within_subj(X)
%
% Returns standard error of every column in X after removing between
%   subject variability. Subjects in rows, conditions in columns.
%
% In short, each subject's deviation from the grand mean is subtracted 
%   from their scores before calculating the standard error.
%   (This method was described by Loftus & Masson, 1994, Table 3)

Gm = mean(X(:));    % Grand mean
Sm = mean(X,2);     % Subject mean
dX = Sm - Gm;    % Deviation of subject mean from grand mean
cX = X - repmat(dX, 1, size(X,2));  % Corrected data
err = sem(cX);  % Corrected standard error
