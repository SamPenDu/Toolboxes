function GenMovGif(matmov, fname, scaled, framedur)
%GenMovGif(matmov, fname, scaled, framedur)
%
% Saves the movie matmov as the GIF file fname.
%
% You can scale the image by using scaled & define the frame durations
% using framedur. This is either a scalar (for all frames) or a vector with
% the duration for each individual frame.
%


if nargin < 3
    scaled = 1;
    framedur = 0;
elseif nargin < 4
    framedur = 0;
end

if strcmpi(class(matmov), 'double')
    matmov = uint8(matmov*255);
end

x = size(matmov, 2);
y = size(matmov, 1);
if size(matmov,4) > 1
    z = size(matmov,4);
else
    z = size(matmov,3);
    map = colormap(gray(256));
end

% turn frame dur into a vector
if length(framedur) == 1
    framedur = ones(1,z) * framedur;
end

h = waitbar(0, 'Frames completed');

%play forward
for i = 1:z 
    if scaled ~= 1
        if size(matmov,4) > 1
            [img map] = rgb2ind(imresize(matmov(:,:,:,i), scaled, 'bicubic'), 256); 
        else
            img = imresize(matmov(:,:,i), scaled, 'bicubic'); 
        end
    else
        if size(matmov,4) > 1
            [img map] = rgb2ind(matmov(:,:,:,i), 256); 
        else
            img = matmov(:,:,i); 
        end
    end
    waitbar(i/z, h);
    if i == 1
        imwrite(img, map, [fname '.gif'], 'DelayTime', framedur(i), 'LoopCount', Inf);
    else
        imwrite(img, map, [fname '.gif'], 'WriteMode', 'Append', 'DelayTime', framedur(i));
    end
end

close(h);
close all;