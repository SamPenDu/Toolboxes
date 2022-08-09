function CreateStudy(sname, extra_subject_details, extra_subject_detail_classes)
%CreateStudy(sname, [extra_subject_details, extra_subject_detail_classes])
%
% Creates a new study sname. If extra_subject_details is defined, these fields will
% be used *in addition* to the default details: 
%
%   Initials, Age, Gender, and Handedness
%
% extra_subject_detail_classes is a string with '-' or '#' for each extra detail.
% '#' indicates an integer type, '-' a string type.

%make sure existing study is not overwritten
if exist([sname '.subj'], 'file')
    b = questdlg('Study already exists. Overwrite?', 'Warning!', 'Yes', 'No', 'No');
    if strcmp(b, 'No')
        %if not to be overwritten end function
        disp('Study will not be overwritten.'); 
        disp(' ');
        return;
    end
end

%add extra subject details if they are defined
subject_details = {'Initials' 'Age' 'Gender' 'Handedness'};
subject_detail_classes = '-#--';
n = length(subject_details);
%if extra details were defined
if nargin > 1
    if ischar(extra_subject_details)
        extra_subject_details = {extra_subject_details};
    end
    for f = 1:length(extra_subject_details)
        subject_details{f+n} = extra_subject_details{f};
    end
    %if classes of extra details undefined
    if nargin < 3
        extra_subject_detail_classes = repmat('-', 1, length(extra_subject_details));
    end
else
    extra_subject_detail_classes = [];
end
subject_detail_classes = [subject_detail_classes, extra_subject_detail_classes];

%save subject data again
save([sname '.subj'], '-mat', '-v6', 'subject_details', 'subject_detail_classes');
disp(['Saved study: ' sname]);
disp(' ');