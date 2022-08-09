function imgOut = InvertContrast(imgIn)
%imgOut = InvertContrast(imgIn)
%
% Inverts the contrast of a greyscale image (must be uint8 class).
%
    
imgIn = double(imgIn);
imgOut = abs(imgIn-255);
imgOut = uint8(imgOut);
imgOut(imgOut==128) = 127;
