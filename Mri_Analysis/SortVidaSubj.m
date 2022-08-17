function SortVidaSubj(S)
%
% Once splitting a folder full of Vida 3D Niftis into subjects, use this
% function to sort a given subject S into 4D NIIs for each run. These will
% be saved in the subfolder ./spm. It assumes that functional runs are
% named BOLD_Run_# (where # is the number). If there is a long MPRAGE, this
% is renamed T1_[SubjectID].nii and moved to ./mri. If there are short
% MPRAGE scans these are moved to ./spm.

cd(S);
mkdir spm
mkdir mri

%% Functional data
n = Inf; % Number of volumes per run
r = 1; % Run number
% Loop thru runs until there aren't any
while n > 0
    f = dir(['*_BOLD_Run_' n2s(r) '.nii']); 
    f = {f.name}';
    disp(f);
    n = length(f);
    % If there are any volumes
    if n > 0
        disp(['Run #' n2s(r) ': ' n2s(n) ' volumes']);
        spm_file_merge(f, ['spm\Run_' n2s(n) 'vols_' n2s(r) '.nii'], 0); % Merge into 4D
        r = r + 1; % Increment run counter
    end
    new_line;
end

%% Structural data
f = dir('*MPRAGE_Long.nii');
if ~isempty(f) 
    if length(f) == 1
        f = f.name;
        dos(['move ' f ' mri\T1_' S '.nii']);
    else
        disp('Why are there so many long T1s?');
        disp({f.name}');
        return
    end
end
% Move any existing short T1s 
dos('move *MPRAGE_Short.nii spm');
dos('del *.nii');

cd ..