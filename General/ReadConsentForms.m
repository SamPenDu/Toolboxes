function ReadConsentForms(Filename, AfterDate, Q_ContactAllowed, Q_Name, Q_Email)
%
% ReadConsentForms(Filename, AfterDate, Q_ContactAllowed, Q_Name, Q_Email)
%
% Checks the CSV sheet Filename with consent forms whether subjects want to
% be contacted for more experiments. If no other inputs are defined, the
% function simply returns the whole table.
%
% AfterDate is a string of the date before which entries will be excluded.
% This should be in format 'YYYY-MM-DD'. Leave empty if not needed.
%
% Q_ContactAllowed is the string naming the column with consent for recontact.
%   If left empty, this will return all names and emails.
%
% Q_Name is the string naming the column with subject names.
%
% Q_Email is the string naming the column with subject emails.
%

warning off
T = readtable(Filename);
warning on
clc

if nargin == 1
    disp(T);
else
    % Which subjects consented to recontact?
    if isempty(Q_ContactAllowed)
        IsContactAllowed = true(size(T,1),1);
    else
        IsContactAllowed = strcmpi(T.(Q_ContactAllowed), 'Yes please');
    end
    
    % Restrict date range?
    if isempty(AfterDate)
        IncludeRows = true(size(T,1),1);
    else
        IncludeRows = T.StartDate >= datetime(AfterDate);
    end
    IsContactAllowed = IsContactAllowed & IncludeRows;
    
    % Identities
    N = T.(Q_Name); % Names
    E = T.(Q_Email); % Emails
    disp('Names');
    disp(N(IsContactAllowed));
    new_line;
    disp('Emails');
    disp(E(IsContactAllowed));
    new_line;
end