function img = CheckerBoard(width, chsz)
%img = CheckerBoard(radius, chsz)
% Returns a bitmap image of a checkerboard pattern.
% The image is a square with width in pixels. 
% chsz is the size of the checks in pixels.
%

checkerboard = [0 1; 1 0];
img = ones(width, width)/2;

for x = 0 : width-1
    for y = 0 : width-1
        img(y+1,x+1) = checkerboard(mod(floor(x/chsz),2)+1, mod(floor(y/chsz),2)+1); 
    end
end

