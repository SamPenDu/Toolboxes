function C = GammaCorrect(I,Gamma)
% C = GammaCorrect(I,Gamma)
%

I = double(I);
C = 255 * (I/255) .^ Gamma;


