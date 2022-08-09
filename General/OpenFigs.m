clear all;

fs = input('How many figures? ');
% fs = 4;

for n = 1 : fs
    fs = uigetfile({'*.fig;*.tif'});
    f{n} = fs;
end

for n = 1 : length(f)
    disp(f{n});
    [pname fname exten] = fileparts(f{n});
    if strcmp(exten, '.tif')
        im = imread(f{n});
        figure; 
        imshow(im);
    else
        open(f{n});
%         reformatFig;
    end
end