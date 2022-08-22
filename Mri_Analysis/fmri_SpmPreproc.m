function fmri_SpmPreproc(Subj)
% Define these variables and save them in 'Preprocessing.mat':
%   RealignUnwarp
%   Coregistration
%

%% Basic parameters
disp('Preprocessing data...');
new_line;
cd([Subj filesep 'spm']);
niis = dir('Run_*.nii');
niis = {niis.name}';
disp(' Realigning runs:');
new_line;
disp(niis);
cs = cd;
ExpFolder = [cs filesep];
sl = strfind(cs, filesep);
cs = cs(sl(end)+1:end);
refimg = ['..' filesep 'mri' filesep 'T1_' Subj '.nii'];
Prefix = '';
% Load preprocessing parameters
load('fmri_Preprocessing.mat');

%% Realign & Unwarp
if exist('RealignUnwarp','var')
    % Loop through selected files
    for i = 1:length(niis)
        hdr = spm_vol([ExpFolder Prefix niis{i}]);
        nvols = length(hdr);
        % Select all volumes
        fs = {};
        for j = 1:nvols
            fs{j} = [ExpFolder Prefix niis{i} ',' n2s(j)];
        end
        fs = fs';
        % Create new session
        RealignUnwarp{1}.spm(1).spatial(1).realignunwarp.data(i).scans = fs;
        if exist('Field_maps', 'dir')
            fmRun = ['Field_maps' filesep niis{i}(1:end-4)];
            fmFile = dir([fmRun filesep 'vdm5_*.nii']);
            fmFile = [fmRun filesep fmFile(1).name ',1'];
            % Preprocessed VDM file for this run
            RealignUnwarp{1}.spm(1).spatial(1).realignunwarp.data(i).pmscans = {fmFile};
        end
    end

    save(['Ruw_' cs]);
    spm_jobman('run', RealignUnwarp);
    close all;
    
    Prefix = ['u' Prefix];
end

%% Coregistration
disp(' Coregistration with T1...');
if exist('Coregistration','var')
    % Select reference & source
    Coregistration{1}.spm(1).spatial(1).coreg.estimate.ref = {[refimg ',1']};
    mf = dir([ExpFolder 'mean*.nii']);
    Coregistration{1}.spm(1).spatial(1).coreg.estimate.source = {[ExpFolder mf(1).name ',1']};

    % Loop through selected files
    fs = {}; k = 0;
    for i = 1:length(niis)
        hdr = spm_vol([ExpFolder Prefix niis{i}]);
        nvols = length(hdr);
        % Select all volumes
        for j = 1:nvols
            k = k + 1;
            fs{k} = [ExpFolder Prefix niis{i} ',' n2s(j)];
        end
    end
    if size(fs,1) == 1
        fs = fs';
    end
    Coregistration{1}.spm(1).spatial(1).coreg.estimate.other = fs;

    save(['Coreg_' cs]);
    spm_jobman('run', Coregistration);
    close all;
end

%% Check coregistration
blanks = length([ExpFolder refimg]) - length([ExpFolder Prefix niis{end}]); 
if sign(blanks) < 0
    ref_vs_epi = [ExpFolder refimg ',1' repmat(' ',1,-blanks); ExpFolder Prefix niis{end} ',1'];
elseif sign(blanks) > 0
    ref_vs_epi = [ExpFolder refimg ',1'; ExpFolder Prefix niis{end} ',1' repmat(' ',1,blanks)];
else
    ref_vs_epi = [ExpFolder refimg ',1'; ExpFolder Prefix niis{end} ',1'];
end
spm_check_registration(ref_vs_epi);
new_line;
disp(' Please check coregistration!');
new_line;
dos('del *.mat');
cd ../..