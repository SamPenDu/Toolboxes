function nimg = imadjcon(img, con)
%
% nimg = imadjcon(img, con)
%
% Adjusts the contrast of the image img to the new contrast con. 
% Returns the new image in double format. 
%

if isa(img, 'uint8')
    img = double(img) / 255;
end

% Difference from medium grey
dif = img - 0.5;

% Adjust contrast
nimg = 0.5 + dif*con;
