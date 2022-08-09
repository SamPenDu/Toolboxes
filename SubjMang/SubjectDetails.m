function details = SubjectDetails(sname, whichdetail)
%details = SubjectDetails(sname, whichdetail)
%
% Returns details defined by whichdetail from the subjects in study sname.
%

%load the subject details
load([sname '.subj'], '-mat');

%empty cell array
details = {};

%add field for each subject
if isfield(Ss, whichdetail)
    for i = 1:length(Ss) 
        details{i} = getfield(Ss(i), whichdetail); 
    end
end
