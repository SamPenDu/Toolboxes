function Ren_Contrast(Cnum, Cname)
%Ren_Contrast(Cnum, Cname)
%
% Saves spmT_00[Cnum].img as [Cname].nii.

C = num2str(Cnum);
if length(C) == 1
    C = ['0' C];
end

hdr = spm_vol(['con_00' C '.img']);
% hdr = spm_vol(['spmT_00' C '.img']);
img = spm_read_vols(hdr);
hdr.fname = [Cname '.nii'];
spm_write_vol(hdr,img);
