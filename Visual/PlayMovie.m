function PlayMovie(matmov, cycles, fdelay)
%
% PlayMovie(matmov, [cycles=1, fdelay=0.01])
%
% Plays the movie defined by matmov. The movie is an Y x X x Z matrix, 
% where X and Y are coordinates, Z is the frame number, and each value 
% defines the luminance of that pixel. The optional inputs cycles define
% how often the movie repeats and fdelay defines how many seconds to
% pause after each frame.
%

if nargin == 1
    cycles = 1;
    fdelay = 0.01;
elseif nargin == 2
    fdelay = 0.01;
end

dims = [size(matmov,1) size(matmov,2)];
if size(matmov,4) > 1
    numfr = size(matmov,4);
else
    numfr = size(matmov,3);
end

figure; axis off; maximize;
set(gcf, 'Units', 'pixels'); 
set(gcf, 'MenuBar', 'none');
set(gcf, 'Color', [.5 .5 .5]);
set(gcf, 'NumberTitle', 'off');

imshow(uint8(ones(dims(1), dims(2))*127));
pause(0.5);

for cy = 1:cycles
    for fr = 1:numfr
        if size(matmov,4) > 1
            imshow(matmov(:, :, :, fr));
        else
            imshow(matmov(:, :, fr));
        end
        pause(fdelay);
    end
end

close all;