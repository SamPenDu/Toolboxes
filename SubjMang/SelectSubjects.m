function Snums = SelectSubjects(sname, singsub)
%Snums = SelectSubjects(sname, [singsub])
%
% Opens list dialog of subject initials to be selected.
% Once selected it returns vector with subject numbers.
% If two input arguments are defined, only one subject
% can be selected.
%

if nargin == 0
    sname = uigetfile('*.subj', 'Select study');
    [pname sname ext] = fileparts(sname);
end

load([sname '.subj'], '-mat');
SubjID = {Ss.ID};

if nargin > 1
    Snums = listdlg('PromptString', 'Select subjects', 'ListString', SubjID, 'SelectionMode', 'single');
else
    Snums = listdlg('PromptString', 'Select subjects', 'ListString', SubjID);
end