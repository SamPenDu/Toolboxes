function details = LoadSubjects(sname, numsub)
%details = LoadSubjects(sname, numsub)
%
% Returns details defined by numsub from the subjects in study sname.
% numsub may also be the subject initials rather than their number.
%

if nargin == 0
    sname = uigetfile('*.subj', 'Select study');
    [pname sname ext] = fileparts(sname);
end

if nargin < 2
    numsub = SelectSubjects(sname);
end

if numsub == 0
    details = struct;
    details.Initials = 'Demo';
elseif ischar(numsub)   % if initials are defined instead of number
    ns = GetNumberOfSubjects(sname);
    %load the subject details
    load([sname '.subj'], '-mat');
    for i = 1:ns
        if strcmpi(Ss(i).Initials, numsub)
            details = Ss(i);
        end
    end
else
    %load the subject details
    load([sname '.subj'], '-mat');
    details = Ss(numsub);
end