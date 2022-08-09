function nii2hdrimg(fname)
% Converts the single-file Nifty fname to Analyze (HDR & IMG) format.

% Load Analyze format
nii = spm_vol([fname '.nii']);
img = spm_read_vols(nii);

% Create Nifty format
hdr = nii;
hdr.fname = [fname '.img'];
spm_write_vol(hdr, img);