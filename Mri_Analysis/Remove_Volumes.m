function Remove_Volumes(fn,rv)
%
% Remove_Volumes(fn,rv)
%
%   Removes volumes in vector rv from file fn (.nii assumed). 
%   Saves the file with the prefix 'rv_'.
%

fn = [fn '.nii'];
hdr = spm_vol(fn);
nvols = length(hdr);
vols = 1:nvols;
vols(rv) = [];

fs = {}; j = 1;
for i = vols
    fs{j} = [fn ',' n2s(i)];
    j = j + 1;
end

spm_file_merge(fs, ['rv_' fn]);
