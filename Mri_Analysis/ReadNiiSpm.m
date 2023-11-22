function [img, hdr] = ReadNiiSpm(NiiFile)
%
% [img, hdr] = ReadNiiSpm(NiiFile)
%
% Reads NII in NiiFile (without extension) using SPM functions. 
% Returns image matrix img & header hdr.

hdr = spm_vol([NiiFile '.nii']);
img = spm_read_vols(hdr);

