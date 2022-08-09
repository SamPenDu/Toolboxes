function simg = imsmooth(img, sigma)
%
% simg = imsmooth(img, sigma)
%
% Smoothes image img with a Gaussian kernel with standard deviation sigma.
% If sigma is negative it applies unsharp masking, it subtracts the smoothed
% image from the original. Returns an image in double format. 
%
% (Uses the imfilter and fspecial from the Image Processing toolbox)
%

if isa(img, 'uint8')
    img = double(img) / 255;
end

if abs(sigma) > 0
    % Dimensions of image
    x = size(img,2); % Horizontal side
    y = size(img,1); % Vertical side

    % Filter image
    f = fspecial('gaussian', min([x y]), abs(sigma));
    simg = imfilter(img, f, 'replicate');
else
    simg = img;
end

if sigma < 0
    % Unsharp masking
    simg = img - simg + 0.5; 
end