function SaveNiiSlices(Subj)
%% Saves out slices of a NII file

hdr = spm_vol([Subj '.nii']);
nii = spm_read_vols(hdr);

mkdir(Subj);
cd(Subj);
% Coronal slices
for x = 1:size(nii,1)
    img = squeeze(nii(x,:,:));
    imwrite(rot90(img/max(img(:)),2), ['Cor-' n2s(x) '.png']);
end
% Transverse slices
for y = 1:size(nii,2)
    img = squeeze(nii(:,y,:));
    imwrite(img/max(img(:)), ['Tra-' n2s(y) '.png']);
end
% Sagital slices
for z = 1:size(nii,3)
    img = squeeze(nii(:,:,z));
    imwrite(rot90(img/max(img(:))), ['Sag-' n2s(z) '.png']);
end