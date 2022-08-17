function SplitSsVidaNiis(Ss)
%
% After importing Vida Dicoms into Nifti all subjects are in the same folder.
% Use this script to strip the folder of junk & move individual subjects
% into their own subfolders folders. Ss is a cell array with subject IDs.

% Remove junk
dos('del *.json');
dos('del *mosaic*');
dos('del *localizer*');

% Loop thru subjects
for i = 1:length(Ss)
    mkdir(Ss{i}); % Make subfolder
    dos(['move ' Ss{i} '_*.nii ' Ss{i}]); % Move subject's files 
end