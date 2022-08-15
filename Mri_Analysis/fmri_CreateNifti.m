function fmri_CreateNifti(Subj, NumDummyVols)

%% Default dummies
if nargin < 2
    NumDummyVols = 0;
end

%% Select all Dicom files
cd([Subj '/dicom']);
fn = dir('*R*'); % *.ima at BUCNI 
mh = 0;
for i = 1:length(fn) 
    if length(fn(i).name) > mh
        mh = length(fn(i).name);
    end
end
P = repmat(' ', length(fn), mh);

%% Create SPM-style file list
for i = 1:length(fn) 
    P(i,1:length(fn(i).name)) = fn(i).name; 
end
P = char(P); % Convert into strings

%% Convert Dicom to Nifti format
disp('Converting IMA to NII format...');
hdr = spm_dicom_headers(P);
spm_dicom_convert(hdr,'all','flat','nii');

%% Move data to new SPM folder
mkdir('../spm');
cd('../spm');
dos('move ../dicom/*.nii .');

%% Rename structurals
dos(['move s*-000208-01.nii T1_' Subj '.nii']);

%% Copy T1 to mri folder & convert to MGZ
mkdir('../mri');
dos(['copy T1_' Subj '.nii ../mri']);

%% Create 4D niftis
rn = dir('f*-00001-000001-01.nii');
rn = {rn.name}';
% Bias correct & merge runs
for r = 1:length(rn)
    % Find all NIIs of this run
    fn = dir([rn{r}(1:end-19) '*.nii']);
    fn = {fn.name}';
    cur_run_vols = length(fn);
    cur_run_name = ['Run_' num2str(cur_run_vols) 'vols_'];
    cur_run_num = dir([cur_run_name '*.nii']);
    cur_run_num = length(cur_run_num) + 1;
    % Bias correct
    if length(fn) >= NumDummyVols+1
        spm_biascorrect(fn(NumDummyVols+1:end));
        dos('del BiasField_*.nii'); % Delete the bias field after it's used
        % Find all bias corrected NIIs of this run
        fn = dir(['b' rn{r}(1:end-19) '*.nii']);
        fn = {fn.name}';
        % Merge into 4D
        spm_file_merge(fn, [cur_run_name num2str(cur_run_num) '.nii'], 0);
    else
        disp([fn(1) ' only has ' num2str(length(fn)) ' volumes so skipping it...']);
    end
end

%% Clean up
dos('del *.mat');
dos('del s*.nii');
dos('del f*.nii');
dos('del bf*.nii');
dos('del c?f*.nii');
clc
disp([' ' Subj ' data converted:']);
new_line;
disp(rn);
new_line;
rn = dir('*.nii');
rn = {rn.name}';
disp(rn);
cd ../..
