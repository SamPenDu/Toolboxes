function hdrimg2nii(fname)
% Converts the Analyze file (HDR & IMG) fname to single-file Nifty format.

% Load Analyze format
hdr = spm_vol([fname '.img']);
img = spm_read_vols(hdr);

% Create Nifty format
nii = hdr;
nii.fname = [fname '.nii'];
spm_write_vol(nii, img);