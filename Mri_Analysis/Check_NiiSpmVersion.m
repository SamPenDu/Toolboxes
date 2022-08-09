function SpmV = Check_NiiSpmVersion(F)
% Uses the data type field in a NII header to infer 
% whether a file was created by SPM8 or SPM12.
%
% If no output is defined it simply stats the verion on the screen.
% If an output is defined, the function returns the SPM number.
%

% File name?
if nargin == 0
    [F,P] = uigetfile('*.nii');
else
    P = '.';
end
F = [P filesep F];

% Load header
hdr = spm_vol(F);

% Data type field
dt = hdr(1).dt(1);

% Make an inference
if dt == 4
    if nargout == 0
        disp('SPM8');
    else
        SpmV = 8;
    end
elseif dt == 512
    if nargout == 0
        disp('SPM12');
    else
        SpmV = 12;
    end
else
    if nargout == 0
        disp('No idea...');
    else
        SpmV = NaN;
    end
end