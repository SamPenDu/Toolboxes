function AddNewSubject(sname)
%AddNewSubject(sname)
%
% Adds a new subject to study sname. Open a dialog box to ask for details. 
% If you need more than the basic details, simply adapt this function.
%

if nargin == 0
    sname = uigetfile('*.subj', 'Select study');
    [pname sname ext] = fileparts(sname);
end

%retrieve number of subjects in study
nS = GetNumberOfSubjects(sname);

%load the subject details
disp(['Current number of subjects: ' num2str(nS)]);
load([sname '.subj'], '-mat');

%open dialogue box & return new details
new_details = inputdlg(subject_details, ['Subject ' num2str(nS+1) ' details'], 1);
%create structure for current subject
curr = struct;
for f = 1:length(subject_details)
    if subject_detail_classes(f) == '#'
        new_details{f} = str2num(new_details{f});
    end
    curr = setfield(curr, subject_details{f}, new_details{f});
end
%add details to current study
if nS == 0
    Ss = curr;
else
    Ss = [Ss; curr];
end

%save subject data again
save([sname '.subj'], '-mat', '-v6', 'Ss', 'subject_details', 'subject_detail_classes');
disp(['Saved study: ' sname]);