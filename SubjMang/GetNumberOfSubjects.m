function nS = GetNumberOfSubjects(sname)
%nS = GetNumberOfSubjects(sname)
%
% Returns the current number of subjects in study sname (in current folder).
%

%if study does not exist end function
if exist([sname '.subj'])
    load([sname '.subj'], '-mat');
else
    disp('Study does not exist!');
    disp(' ');
    nS = 0;
    return;
end

%if Ss undefined, number of subjects is 0
if exist('Ss')
    nS = length(Ss);
else
    nS = 0;
end




