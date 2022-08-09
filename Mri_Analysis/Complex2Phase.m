function Complex2Phase(fimag)
% Converts imag and real maps into a phase map. 

% Select files
if nargin < 1
    [fimag pn] = uigetfile('*_imag.nii');
    hdr_imag = spm_vol([pn fimag]);
end
freal = [fimag(1:end-9) '_real.nii'];
hdr_real = spm_vol([pn freal]);

% Load images
img_imag = spm_read_vols(hdr_imag);
img_real = spm_read_vols(hdr_real);

% Convert to phase
hdr = hdr_imag;
hdr.fname = [hdr.fname(1:end-9) '_phase.nii'];
img = atan2(img_imag, img_real) / pi * 180;

% Save phase map
spm_write_vol(hdr, img);