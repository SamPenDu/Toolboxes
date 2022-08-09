function fimg = imbandpass(img, bp)
%
% fimg = imbandpass(img, bp)
%
% Bandpass filters an image using fast Fourier transform & normalises it.
% Currently, this internally converts images to grey scale.
% Returns the filtered image in double format.
%

if isa(img, 'uint8')
    img = double(img) / 255;
end
if size(img,3) > 1
    img = rgb2gray(img);
end

% Dimensions
w = size(img);
[x,y] = ndgrid(1:w(1), 1:w(2));
x = x - w(1)/2;
y = y - w(2)/2;
r = sqrt(x.^2 + y.^2); % Distance from centre

% Fourier transform
f = fft2(img);
f = fftshift(f);
f(r<bp(1) | r>bp(2)) = 0;
f = ifftshift(f);
fimg = ifft2(f);
fimg = real(fimg);

% Normalise intensity
fimg = fimg / max(fimg(:)) * 0.5 + 0.5;