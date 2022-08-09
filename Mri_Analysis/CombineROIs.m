function CombineROIs(f, fname)

if nargin == 0
    [f p] = uigetfile('*.nii;*.img', 'Multiselect', 'on');
    if ischar(f)
        f = {f};
    end
else
    for i = 1:length(f)
        f{i} = [f{i} '.nii'];
    end
    p = cd;
end

% loop through files
for i = 1:length(f)
    hdr = spm_vol([p filesep f{i}]);
    % If first file, get dimensions
    if i == 1
        dimen = hdr.dim;
        nimg = zeros(dimen);
    end
    % load ROI image
    img = spm_read_vols(hdr);
    
    % Add ROI voxels to new ROI
    nimg(img > 0) = 1;
end

if nargin < 2
    fname = inputdlg('ROI name: ', 'Save file');
end
if iscell(fname)
    fname = fname{1};
end

nhdr = hdr;
nhdr.fname = [fname '.nii'];

spm_write_vol(nhdr, nimg);
