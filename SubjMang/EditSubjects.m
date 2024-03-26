function EditSubjects(sname, num)
%EditSubjects(sname, [num])
%
% Edits subject details to study sname. Opens a dialog box for details. 
% The subjects to be edited is selected via a list dialogue.
%

if nargin == 0
    sname = uigetfile('*.subj', 'Select study');
    [pname sname ext] = fileparts(sname);
end

%retrieve number of subjects in study
nS = GetNumberOfSubjects(sname);

%load the subject data
disp(['Current number of subjects: ' num2str(nS)]);
load([sname '.subj'], '-mat');

%select the subjects to be edited
eS = SelectSubjects(sname);

for i = eS
    subject_details = fieldnames(Ss(i))';    
    %get the default values
    defaults = {};
    for f = 1:length(subject_details)
        defaults{f} = getfield(Ss(i), subject_details{f});
        %default values must be strings
        if strcmp(class(defaults{f}), 'double')
            defaults{f} = num2str(defaults{f});
        end
    end
    
    %open dialogue box & return new values 
    new_details = inputdlg(subject_details, ['Subject ' num2str(i) ' details'], 1, defaults);
    %add details to current study
    if ~isempty(new_details)
        curr = struct;
        for f = 1:length(subject_details)
            if subject_detail_classes(f) == '#'
                new_details{f} = str2num(new_details{f});
            end
            curr = setfield(curr, subject_details{f}, new_details{f});
        end
        Ss(i) = curr;
    end
end

%save subject data again
save([sname '.subj'], '-mat', '-v6', 'Ss', 'subject_details', 'subject_detail_classes');
disp(['Saved study: ' sname]);
