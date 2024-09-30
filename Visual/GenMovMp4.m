function GenMovMp4(matmov, fname, scaled)
%GenMovMp4(matmov, fname, scaled)
%
% Saves the movie matmov as the MP4 file fname.
% You can scale the image by using scaled.
%


if nargin < 3
    scaled = 1;
end

if strcmpi(class(matmov), 'double')
    matmov = uint8(matmov*255);
end

if size(matmov,4) > 1
    z = size(matmov, 4);
else
    z = size(matmov, 3);
end

%create video object
v = VideoWriter([fname '.mp4'], 'MPEG-4');
v.FrameRate = 60;
open(v);

%play forward
writeVideo(v, matmov);
close(v);

