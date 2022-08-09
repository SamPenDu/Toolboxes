function Anonymise(SubjID, SubjNum)
%
% Renames all the files whose names contain SubjID to instead contain the
% subject number. It also replaces the subject ID in the saved Parameters
% structure with the subject number. SubjNum can however also be a string.
%

% Find all files
f = dir([SubjID '*.mat']);
f = {f.name}';

% Loop thru files
for i = 1:length(f)
    % Determine old & new name
    OldName = f{i};
    s = strfind(OldName, SubjID);
    if ischar(SubjNum)
        NewName = [SubjNum OldName(s+length(SubjID):end)];
    else
        NewName = ['S' num2str(SubjNum) OldName(s+length(SubjID):end)];
    end
    
    % Rename file
    if ispc
        dos(['ren "' OldName '" "' NewName '"']);
    else
        unix(['mv ' OldName ' ' NewName]);
    end
    % Load file & replace Subject ID with number
    Data = load(NewName);
    if ischar(SubjNum)
        Data.Parameters.Subj_ID = SubjNum;
    else
        Data.Parameters.Subj_ID = ['S' num2str(SubjNum)];
    end
    Data.Parameters.Session_name = NewName(1:end-4);
    save(NewName, '-struct', 'Data');
end