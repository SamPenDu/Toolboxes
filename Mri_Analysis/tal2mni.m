function outpoint = tal2mni(inpoint)
% Transform Talairach to MNI coordinates 

Tfrm = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
tmp = inv(Tfrm) * [inpoint; 1];
outpoint = tmp(1:3);
