function GenMovMp4(matmov, fname, scaled)
%GenMovMp4(matmov, fname, scaled)
%
% Saves the movie matmov as the MP4 file fname.
% You can scale the image by using scaled.
%


if nargin < 3
    scaled = 1;
end

if strcmpi(class(matmov), 'uint8')
    matmov = double(matmov/255);
end

z = size(matmov, 3);

%create video object
v = VideoWriter([fname '.mp4'], 'MPEG-4');
v.FrameRate = 60;
open(v);

h = waitbar(0, 'Frames completed');
%play forward
for i = 1:z 
    if scaled ~= 1
        img = imresize(matmov(:,:,i), scaled, 'bicubic'); 
    else
        img = matmov(:,:,i); 
    end
    writeVideo(v, img);
    waitbar(i/z, h);
end
close(v);

close(h);
close all;