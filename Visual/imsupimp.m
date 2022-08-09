function nimg = imsupimp(img, bgd, tra)
% Superimposes img onto bgd with transparent colour tra.
% Both must have the same dimension.

if nargin < 3
    tra = 0;
end

nimg = zeros(size(bgd,1), size(bgd,2), size(bgd,3));

for c = 1:size(bgd,3)
    timg = img(:,:,c);
    tbgd = bgd(:,:,c);
    ntimg = tbgd;
    o = find(timg ~= tra);
    t = find(timg == tra);
    ntimg(t) = tbgd(t); 
    ntimg(o) = timg(o);
    nimg(:,:,c) = ntimg;
end