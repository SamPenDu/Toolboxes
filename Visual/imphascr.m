function ImScrambled = imphascr(img, ps)
% ImScrambled = imphascr(img, [ps=Inf])
%
% Phase scrambles the image in img. This must be a double with values
% between 0-1 or an uint8. The second input argument ps defines the
% standard deviation of the Gaussian phase shift (in factors of pi) that 
% added to the original. This is optional and defaults to Inf, in which 
% case it applies a uniform random phase shift instead.

% Phase shift undefined?
if nargin < 2
    ps = Inf;
end

if isinf(ps)
    % Random phase structure
    RandomPhase = angle(fft2(rand(size(img,1), size(img,2))));
else
    % Phase shift to be added
    RandomPhase = randn(size(img,1), size(img,2)) * ps * pi;
end

for layer = 1:size(img,3)
    ImFourier(:,:,layer) = fft2(img(:,:,layer)); % Fast-Fourier transform
    Amp(:,:,layer) = abs(ImFourier(:,:,layer)); % Amplitude spectrum
    Phase(:,:,layer) = angle(ImFourier(:,:,layer)); % Phase spectrum
    Phase(:,:,layer) = Phase(:,:,layer) + RandomPhase; % Add random phase to original phase
    ImScrambled(:,:,layer) = ifft2(Amp(:,:,layer) .* exp(sqrt(-1)*(Phase(:,:,layer)))); % Combine Amp and Phase then perform inverse Fourier  
end

ImScrambled = real(ImScrambled); % Remove imaginery part in image (due to rounding error)

ImScrambled = ImScrambled - min(ImScrambled(:)); % Shift to remove negative values
ImScrambled = ImScrambled / max(ImScrambled(:)); % Convert to 0-1