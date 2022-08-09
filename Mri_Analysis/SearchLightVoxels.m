function vox = SearchLightVoxels(img, curvox, d)
%
% vox = SearchLightVoxels(img, curvox, d)
%
% Returns the voxels in a searchlight mask from the 3D matrix in img. 
% The mask is a sphere of radius d around voxel curvox (1x3 vector with voxel coordinates).
%
% The output vox contains the voxels as a row vector.

dim = size(img);
[x y z] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
x = x-curvox(1);
y = y-curvox(2);
z = z-curvox(3);
e = sqrt(x.^2+y.^2+z.^2);
v = find(e<=d);
vox = img(v)';